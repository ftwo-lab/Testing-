codeunit 50102 "PIM AI Translator"
{
    procedure TranslateItemToLocale(ItemNo: Code[20]; TargetLocaleCode: Code[10]; OverwriteExisting: Boolean)
    var
        Item: Record Item;
        PIMLocale: Record "PIM Locale";
        SourceLocale: Record "PIM Locale";
        PIMItemLocaleData: Record "PIM Item Locale Data";
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        SourceDescription: Text[100];
        SourceDescription2: Text[50];
        SourceExtendedDescription: Text[2048];
        SourceMarketingText: Text[2048];
        TranslatedDescription: Text[100];
        TranslatedDescription2: Text[50];
        TranslatedExtendedDescription: Text[2048];
        TranslatedMarketingText: Text[2048];
    begin
        if not Item.Get(ItemNo) then
            Error('Item %1 was not found.', ItemNo);

        if not PIMLocale.Get(TargetLocaleCode) then
            Error('Locale %1 was not found.', TargetLocaleCode);

        if PIMLocale."Is Source Locale" then
            Error('Select a target locale other than the source locale.');

        if not SourceLocale.Get(PIMLocaleMgt.GetSourceLocaleCode()) then
            Error('Configure a source locale first.');

        if PIMLocaleMgt.GetItemLocaleData(ItemNo, TargetLocaleCode, PIMItemLocaleData) then
            if not OverwriteExisting then
                if PIMItemLocaleData."Translation Status" in
                   [PIMItemLocaleData."Translation Status"::Reviewed,
                    PIMItemLocaleData."Translation Status"::Published]
                then
                    Error('Translation for locale %1 is already reviewed/published. Enable overwrite to replace it.', TargetLocaleCode);

        PIMLocaleMgt.LoadItemTextsForLocale(
            ItemNo, SourceLocale.Code,
            SourceDescription, SourceDescription2, SourceExtendedDescription, SourceMarketingText);

        TranslatedDescription := TranslateText(SourceDescription, SourceLocale."AI Locale Tag", PIMLocale."AI Locale Tag");
        TranslatedDescription2 := TranslateText(SourceDescription2, SourceLocale."AI Locale Tag", PIMLocale."AI Locale Tag");
        TranslatedExtendedDescription := TranslateText(SourceExtendedDescription, SourceLocale."AI Locale Tag", PIMLocale."AI Locale Tag");
        TranslatedMarketingText := TranslateText(SourceMarketingText, SourceLocale."AI Locale Tag", PIMLocale."AI Locale Tag");

        PIMLocaleMgt.GetItemLocaleData(ItemNo, TargetLocaleCode, PIMItemLocaleData);
        PIMItemLocaleData.Description := CopyStr(TranslatedDescription, 1, MaxStrLen(PIMItemLocaleData.Description));
        PIMItemLocaleData."Description 2" := CopyStr(TranslatedDescription2, 1, MaxStrLen(PIMItemLocaleData."Description 2"));
        PIMItemLocaleData."Extended Description" := CopyStr(TranslatedExtendedDescription, 1, MaxStrLen(PIMItemLocaleData."Extended Description"));
        PIMItemLocaleData."Marketing Text" := CopyStr(TranslatedMarketingText, 1, MaxStrLen(PIMItemLocaleData."Marketing Text"));
        PIMItemLocaleData."Translated by AI" := true;
        PIMItemLocaleData."Last Translated At" := CurrentDateTime();
        PIMItemLocaleData."Translation Status" := PIMItemLocaleData."Translation Status"::"AI Generated";
        PIMLocaleMgt.SaveItemLocaleData(PIMItemLocaleData);

        Message('AI translation completed for locale %1.', PIMLocale.Name);
    end;

    procedure TranslateText(SourceText: Text; SourceLocaleTag: Text[20]; TargetLocaleTag: Text[20]): Text
    var
        PIMAISetup: Record "PIM AI Setup";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        RequestBody: Text;
        ResponseText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        ChoicesArray: JsonArray;
        ChoiceObject: JsonObject;
        MessageObject: JsonObject;
        MessagesArray: JsonArray;
        SystemPrompt: Text;
        UserPrompt: Text;
    begin
        if SourceText = '' then
            exit('');

        PIMAISetup.Get();
        if not PIMAISetup.Enabled then
            Error('Configure PIM AI Setup before using AI translation.');

        SystemPrompt := PIMAISetup."System Prompt";
        if SystemPrompt = '' then
            SystemPrompt := 'You are a professional product content translator for ERP/PIM data. Preserve brand names, measurements, SKU codes, and technical values. Return only the translated text without quotes or explanations.';

        UserPrompt := StrSubstNo(
            'Translate the following product text from %1 to %2:%3%4',
            SourceLocaleTag, TargetLocaleTag, '\n', SourceText);

        Clear(JsonObject);
        JsonObject.Add('model', PIMAISetup."Deployment Name");

        Clear(MessagesArray);
        Clear(MessageObject);
        MessageObject.Add('role', 'system');
        MessageObject.Add('content', SystemPrompt);
        MessagesArray.Add(MessageObject);

        Clear(MessageObject);
        MessageObject.Add('role', 'user');
        MessageObject.Add('content', UserPrompt);
        MessagesArray.Add(MessageObject);

        JsonObject.Add('messages', MessagesArray);
        JsonObject.WriteTo(RequestBody);

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');

        HttpClient.DefaultRequestHeaders().Add('api-key', PIMAISetup."API Key");
        if not HttpClient.Post(PIMAISetup."Endpoint URL", HttpContent, HttpResponseMessage) then
            Error('Could not connect to the AI endpoint.');

        HttpResponseMessage.Content().ReadAs(ResponseText);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error('AI translation failed: %1', CopyStr(ResponseText, 1, 250));

        if not JsonObject.ReadFrom(ResponseText) then
            Error('Invalid AI response.');

        if not JsonObject.Get('choices', JsonToken) then
            Error('AI response did not contain choices.');

        ChoicesArray := JsonToken.AsArray();
        if ChoicesArray.Count() = 0 then
            Error('AI response did not contain translated text.');

        ChoicesArray.Get(0, JsonToken);
        ChoiceObject := JsonToken.AsObject();
        if not ChoiceObject.Get('message', JsonToken) then
            Error('AI response did not contain a message.');

        ChoiceObject := JsonToken.AsObject();
        if not ChoiceObject.Get('content', JsonToken) then
            Error('AI response did not contain content.');

        exit(JsonToken.AsValue().AsText());
    end;
}
