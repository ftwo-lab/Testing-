codeunit 50102 "PIM AI Translator"
{
    procedure TranslateItemToLocale(ItemNo: Code[20]; TargetLocaleCode: Code[10]; OverwriteExisting: Boolean)
    var
        Item: Record Item;
        PIMLocale: Record "PIM Locale";
        SourceLocale: Record "PIM Locale";
        PIMItemLocaleData: Record "PIM Item Locale Data";
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
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

        PIMLocaleMgt.TranslateAllItemFields(ItemNo, TargetLocaleCode, SourceLocale, PIMLocale);

        PIMLocaleMgt.GetItemLocaleData(ItemNo, TargetLocaleCode, PIMItemLocaleData);
        SyncHeaderFromTranslatedFields(Item, PIMItemLocaleData);
        PIMItemLocaleData."Translated by AI" := true;
        PIMItemLocaleData."Last Translated At" := CurrentDateTime();
        PIMItemLocaleData."Translation Status" := PIMItemLocaleData."Translation Status"::"AI Generated";
        PIMLocaleMgt.SaveItemLocaleData(PIMItemLocaleData);

        Message('Translation completed for locale %1.', PIMLocale.Name);
    end;

    local procedure SyncHeaderFromTranslatedFields(Item: Record Item; var PIMItemLocaleData: Record "PIM Item Locale Data")
    var
        PIMItemLocaleField: Record "PIM Item Locale Field";
    begin
        PIMItemLocaleField.SetRange("Item No.", PIMItemLocaleData."Item No.");
        PIMItemLocaleField.SetRange("Locale Code", PIMItemLocaleData."Locale Code");
        PIMItemLocaleField.SetRange("Table No.", Database::Item);
        PIMItemLocaleField.SetRange("Field No.", Item.FieldNo(Description));
        if PIMItemLocaleField.FindFirst() then
            PIMItemLocaleData.Description := CopyStr(PIMItemLocaleField.Value, 1, MaxStrLen(PIMItemLocaleData.Description));

        PIMItemLocaleField.SetRange("Field No.", Item.FieldNo("Description 2"));
        if PIMItemLocaleField.FindFirst() then
            PIMItemLocaleData."Description 2" := CopyStr(PIMItemLocaleField.Value, 1, MaxStrLen(PIMItemLocaleData."Description 2"));
    end;

    procedure ApplyLocaleAndTranslate(ItemNo: Code[20]; LocaleCode: Code[10])
    var
        PIMLocaleMgt: Codeunit "PIM Locale Mgt.";
        PIMLocaleSession: Codeunit "PIM Locale Session";
    begin
        PIMLocaleSession.SetActiveLocale(LocaleCode);

        if LocaleCode = PIMLocaleMgt.GetSourceLocaleCode() then
            exit;

        TranslateItemToLocale(ItemNo, LocaleCode, true);
    end;

    procedure TranslateText(SourceText: Text; SourceLocaleTag: Text[20]; TargetLocaleTag: Text[20]): Text
    var
        PIMAISetup: Record "PIM AI Setup";
    begin
        if SourceText = '' then
            exit('');

        if not PIMAISetup.Get() then
            Error('PIM AI Setup is missing. Open PIM AI Setup and configure it.');

        if not PIMAISetup.Enabled then
            Error('PIM AI Setup is disabled. Open PIM AI Setup and turn Enabled on.');

        case PIMAISetup."AI Provider" of
            PIMAISetup."AI Provider"::Claude:
                exit(TranslateWithClaude(SourceText, SourceLocaleTag, TargetLocaleTag, PIMAISetup));
            PIMAISetup."AI Provider"::"Azure OpenAI":
                exit(TranslateWithAzureOpenAI(SourceText, SourceLocaleTag, TargetLocaleTag, PIMAISetup));
            PIMAISetup."AI Provider"::"Azure Translator":
                exit(TranslateWithAzureTranslator(SourceText, SourceLocaleTag, TargetLocaleTag, PIMAISetup));
            else
                Error('Unsupported AI Provider in PIM AI Setup.');
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
            Error(
              'Azure OpenAI failed (HTTP %1): %2',
              Format(HttpResponseMessage.HttpStatusCode()),
              CopyStr(ResponseText, 1, 250));

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

    local procedure TranslateWithAzureTranslator(SourceText: Text; SourceLocaleTag: Text[20]; TargetLocaleTag: Text[20]; PIMAISetup: Record "PIM AI Setup"): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        RequestBody: Text;
        ResponseText: Text;
        RequestArray: JsonArray;
        RequestObject: JsonObject;
        ResponseArray: JsonArray;
        ResponseObject: JsonObject;
        TranslationsArray: JsonArray;
        TranslationObject: JsonObject;
        JsonToken: JsonToken;
        Url: Text;
        FromLang: Text[10];
        ToLang: Text[10];
    begin
        ValidateAzureTranslatorSetup(PIMAISetup);

        FromLang := MapToTranslatorLanguage(SourceLocaleTag);
        ToLang := MapToTranslatorLanguage(TargetLocaleTag);

        Url := StrSubstNo(
            '%1/translate?api-version=3.0&from=%2&to=%3',
            GetTranslatorEndpoint(PIMAISetup."Endpoint URL", PIMAISetup."API Region"), FromLang, ToLang);

        Clear(RequestObject);
        RequestObject.Add('text', SourceText);
        Clear(RequestArray);
        RequestArray.Add(RequestObject);
        RequestArray.WriteTo(RequestBody);

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');

        HttpClient.DefaultRequestHeaders().Clear();
        HttpClient.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', PIMAISetup."API Key");
        HttpClient.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Region', PIMAISetup."API Region");

        if not HttpClient.Post(Url, HttpContent, HttpResponseMessage) then
            Error('Could not connect to Azure Translator at %1. Check Allow HTTPClient Requests in Extension Management.', Url);

        HttpResponseMessage.Content().ReadAs(ResponseText);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(
              'Azure Translator failed (HTTP %1). Region=%2. Response=%3',
              Format(HttpResponseMessage.HttpStatusCode()),
              PIMAISetup."API Region",
              CopyStr(ResponseText, 1, 250));

        if not ResponseArray.ReadFrom(ResponseText) then
            Error('Invalid Azure Translator response: %1', CopyStr(ResponseText, 1, 250));

        if ResponseArray.Count() = 0 then
            Error('Azure Translator response was empty.');

        ResponseArray.Get(0, JsonToken);
        ResponseObject := JsonToken.AsObject();
        if not ResponseObject.Get('translations', JsonToken) then
            Error('Azure Translator response did not contain translations.');

        TranslationsArray := JsonToken.AsArray();
        if TranslationsArray.Count() = 0 then
            Error('Azure Translator did not return translated text.');

        TranslationsArray.Get(0, JsonToken);
        TranslationObject := JsonToken.AsObject();
        if not TranslationObject.Get('text', JsonToken) then
            if not TranslationObject.Get('Text', JsonToken) then
                Error('Azure Translator response did not contain text.');

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
        if PIMAISetup."API Key" = '' then
            Error('Enter an API Key in PIM AI Setup.');
        if PIMAISetup."Endpoint URL" = '' then
            Error('Enter an Endpoint URL in PIM AI Setup.');
        if PIMAISetup."Deployment Name" = '' then
            Error('Enter a Model / Deployment Name in PIM AI Setup.');
    end;

    local procedure ValidateAzureTranslatorSetup(PIMAISetup: Record "PIM AI Setup")
    begin
        if PIMAISetup."API Key" = '' then
            Error('Enter the Azure Translator key in PIM AI Setup.');
        if PIMAISetup."Endpoint URL" = '' then
            Error('Enter the Azure Translator endpoint in PIM AI Setup.');
        if PIMAISetup."API Region" = '' then
            Error('Enter the API Region in PIM AI Setup, e.g. eastasia.');
    end;

    local procedure MapToTranslatorLanguage(LocaleTag: Text[20]): Code[10]
    begin
        case LowerCase(LocaleTag) of
            'en', 'en-gb', 'enu':
                exit('en');
            'de', 'de-de', 'deu':
                exit('de');
            'de-ch', 'des':
                exit('de');
            else
                exit(CopyStr(LowerCase(LocaleTag), 1, 2));
        end;
    end;

    local procedure GetTranslatorEndpoint(EndpointURL: Text[250]; APIRegion: Code[20]): Text
    var
        RegionText: Text;
    begin
        RegionText := LowerCase(DelChr(APIRegion, '<>', ' '));
        if RegionText <> '' then
            exit('https://' + RegionText + '.api.cognitive.microsofttranslator.com');

        if EndpointURL <> '' then
            exit(DelChr(EndpointURL, '>', '/'));

        exit('https://api.cognitive.microsofttranslator.com');
    end;

    local procedure GetClaudeEndpoint(EndpointURL: Text[250]): Text
    begin
        if EndpointURL = '' then
            exit('https://api.anthropic.com/v1/messages');
        exit(EndpointURL);
    end;
}
