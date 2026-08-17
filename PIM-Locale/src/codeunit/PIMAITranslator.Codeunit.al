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
    begin
        if SourceText = '' then
            exit('');

        PIMAISetup.Get();
        if not PIMAISetup.Enabled then
            Error('Configure PIM AI Setup before using AI translation.');

        case PIMAISetup."AI Provider" of
            PIMAISetup."AI Provider"::Claude:
                exit(TranslateWithClaude(SourceText, SourceLocaleTag, TargetLocaleTag, PIMAISetup));
            PIMAISetup."AI Provider"::"Azure OpenAI":
                exit(TranslateWithAzureOpenAI(SourceText, SourceLocaleTag, TargetLocaleTag, PIMAISetup));
            PIMAISetup."AI Provider"::"Azure Translator":
                exit(TranslateWithAzureTranslator(SourceText, SourceLocaleTag, TargetLocaleTag, PIMAISetup));
        end;
    end;

    local procedure TranslateWithClaude(SourceText: Text; SourceLocaleTag: Text[20]; TargetLocaleTag: Text[20]; PIMAISetup: Record "PIM AI Setup"): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        RequestBody: Text;
        ResponseText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        ContentArray: JsonArray;
        ContentObject: JsonObject;
        MessagesArray: JsonArray;
        MessageObject: JsonObject;
        SystemPrompt: Text;
        UserPrompt: Text;
    begin
        ValidateSetup(PIMAISetup);

        SystemPrompt := GetSystemPrompt(PIMAISetup);
        UserPrompt := BuildUserPrompt(SourceText, SourceLocaleTag, TargetLocaleTag);

        Clear(JsonObject);
        JsonObject.Add('model', PIMAISetup."Deployment Name");
        JsonObject.Add('max_tokens', 2048);
        JsonObject.Add('system', SystemPrompt);

        Clear(MessagesArray);
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

        HttpClient.DefaultRequestHeaders().Clear();
        HttpClient.DefaultRequestHeaders().Add('x-api-key', PIMAISetup."API Key");
        HttpClient.DefaultRequestHeaders().Add('anthropic-version', '2023-06-01');

        if not HttpClient.Post(GetClaudeEndpoint(PIMAISetup."Endpoint URL"), HttpContent, HttpResponseMessage) then
            Error('Could not connect to Claude API.');

        HttpResponseMessage.Content().ReadAs(ResponseText);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error('Claude translation failed: %1', CopyStr(ResponseText, 1, 250));

        Clear(JsonObject);
        if not JsonObject.ReadFrom(ResponseText) then
            Error('Invalid Claude response.');

        if not JsonObject.Get('content', JsonToken) then
            Error('Claude response did not contain content.');

        ContentArray := JsonToken.AsArray();
        if ContentArray.Count() = 0 then
            Error('Claude response did not contain translated text.');

        ContentArray.Get(0, JsonToken);
        ContentObject := JsonToken.AsObject();
        if not ContentObject.Get('text', JsonToken) then
            Error('Claude response did not contain text.');

        exit(JsonToken.AsValue().AsText());
    end;

    local procedure TranslateWithAzureOpenAI(SourceText: Text; SourceLocaleTag: Text[20]; TargetLocaleTag: Text[20]; PIMAISetup: Record "PIM AI Setup"): Text
    var
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
        ValidateSetup(PIMAISetup);

        SystemPrompt := GetSystemPrompt(PIMAISetup);
        UserPrompt := BuildUserPrompt(SourceText, SourceLocaleTag, TargetLocaleTag);

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

        HttpClient.DefaultRequestHeaders().Clear();
        HttpClient.DefaultRequestHeaders().Add('api-key', PIMAISetup."API Key");
        if not HttpClient.Post(PIMAISetup."Endpoint URL", HttpContent, HttpResponseMessage) then
            Error('Could not connect to Azure OpenAI.');

        HttpResponseMessage.Content().ReadAs(ResponseText);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error('Azure OpenAI translation failed: %1', CopyStr(ResponseText, 1, 250));

        Clear(JsonObject);
        if not JsonObject.ReadFrom(ResponseText) then
            Error('Invalid Azure OpenAI response.');

        if not JsonObject.Get('choices', JsonToken) then
            Error('Azure OpenAI response did not contain choices.');

        ChoicesArray := JsonToken.AsArray();
        if ChoicesArray.Count() = 0 then
            Error('Azure OpenAI response did not contain translated text.');

        ChoicesArray.Get(0, JsonToken);
        ChoiceObject := JsonToken.AsObject();
        if not ChoiceObject.Get('message', JsonToken) then
            Error('Azure OpenAI response did not contain a message.');

        ChoiceObject := JsonToken.AsObject();
        if not ChoiceObject.Get('content', JsonToken) then
            Error('Azure OpenAI response did not contain content.');

        exit(JsonToken.AsValue().AsText());
    end;

    local procedure GetSystemPrompt(PIMAISetup: Record "PIM AI Setup"): Text
    begin
        if PIMAISetup."System Prompt" <> '' then
            exit(PIMAISetup."System Prompt");

        exit('You are a professional product content translator for ERP/PIM data. Preserve brand names, measurements, SKU codes, and technical values. Return only the translated text without quotes or explanations.');
    end;

    local procedure BuildUserPrompt(SourceText: Text; SourceLocaleTag: Text[20]; TargetLocaleTag: Text[20]): Text
    begin
        exit(StrSubstNo('Translate the following product text from %1 to %2:%3%4', SourceLocaleTag, TargetLocaleTag, '\n', SourceText));
    end;

    local procedure ValidateSetup(PIMAISetup: Record "PIM AI Setup")
    begin
        if PIMAISetup."Endpoint URL" = '' then
            Error('Enter an Endpoint URL in PIM AI Setup.');
        if PIMAISetup."Deployment Name" = '' then
            Error('Enter a Model / Deployment Name in PIM AI Setup.');
        if PIMAISetup."API Key" = '' then
            Error('Enter an API Key in PIM AI Setup.');
    end;

    local procedure GetClaudeEndpoint(EndpointURL: Text[250]): Text
    begin
        if EndpointURL = '' then
            exit('https://api.anthropic.com/v1/messages');
        exit(EndpointURL);
    end;
}
