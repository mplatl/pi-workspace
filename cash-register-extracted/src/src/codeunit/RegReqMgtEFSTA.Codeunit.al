codeunit 1070547 "CCS CASH Reg. Req.Mgt. EFSTA"
{
    Access = Internal;

    var
        NoRequestBodyErr: Label 'Request body is not set';
        NoServiceAddressErr: Label 'Web Service URL is not set';
        ResponseBodyTempBlob: Codeunit "Temp Blob";
        GlobalRequestBodyInStream: InStream;
        HttpWebResponse: HttpResponseMessage;
        [NonDebuggable]
        GlobalPassword: Text;
        GlobalURL: Text;
        GlobalUsername: Text;
        GlobalTimeout: Integer;
        GlobalSkipCheckHttps: Boolean;
        GlobalAction: Text;
        BasicAuthMode: Boolean;
        NoBodyContentNeeded: Boolean;
        ContentTypeNew: Label 'application/json; charset=utf-8';

    [TryFunction]
    internal procedure SendRequestToWebService()
    begin
        CheckGlobals();

        SendRequestToWebServiceBA(GlobalRequestBodyInStream, GlobalURL, GlobalUsername, GlobalPassword, GlobalAction);
    end;

    local procedure ExtractContentFromResponse(ResponseInStream: InStream; var BodyTempBlob: Codeunit "Temp Blob")
    var
        BodyOutStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutStream);
        CopyStream(BodyOutStream, ResponseInStream);
    end;

    internal procedure GetResponseContent(var ResponseBodyInStream: InStream)
    begin
        ResponseBodyTempBlob.CreateInStream(ResponseBodyInStream);
    end;

    internal procedure SetGlobals(RequestBodyInStream: InStream; URL: Text; Username: Text; Password: Text; ParamAction: Text)
    begin
        GlobalRequestBodyInStream := RequestBodyInStream;

        GlobalSkipCheckHttps := false;

        GlobalURL := URL;
        GlobalUsername := Username;
        GlobalPassword := Password;

        // ++ FS
        GlobalAction := ParamAction;
        // -- FS
    end;

    internal procedure SetTimeout(NewTimeout: Integer)
    begin
        GlobalTimeout := NewTimeout;
    end;

    local procedure CheckGlobals()
    var
        WebRequestHelper: Codeunit "Web Request Helper";
    begin
        if not NoBodyContentNeeded then
            if GlobalRequestBodyInStream.EOS then
                Error(NoRequestBodyErr);

        if GlobalURL = '' then
            Error(NoServiceAddressErr);

        if GlobalSkipCheckHttps then
            WebRequestHelper.IsValidUri(GlobalURL)
        else
            WebRequestHelper.IsSecureHttpUrl(GlobalURL);
    end;

    internal procedure DisableHttpsCheck()
    begin
        GlobalSkipCheckHttps := true;
    end;

    [TryFunction]
    local procedure SendRequestToWebServiceBA(BodyContentInStream: InStream; URI: Text; Username: Text; Password: Text; ActionCode: Text)
    var
        RequestHeaders: HttpHeaders;
        client: HttpClient;
        content: HttpContent;
        contentHeaders: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        ResponseInStream: InStream;
        Base64Convert: Codeunit "Base64 Convert";
        XMLContent: Text;
        RequestHasNoError: Boolean;
    begin
        // For Basic Authentication
        RequestHeaders := client.DefaultRequestHeaders();
        if Username <> '' then begin
            RequestHeaders.Add('PreAuthenticate', 'true');
            RequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64(Username + ':' + Password));
        end;
        IF GlobalTimeout = 0 then
            RequestHeaders.Add('Timeout', '600000')
        else
            RequestHeaders.Add('Timeout', FORMAT(GlobalTimeout));

        if not NoBodyContentNeeded then
            if not BodyContentInStream.EOS then begin
                BodyContentInStream.Read(XMLContent);
                if XMLContent <> '' then begin
                    content.WriteFrom(XMLContent);
                    content.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', ContentTypeNew);
                end;
            end;

        case ActionCode of
            'PUT':
                RequestHasNoError := client.Put(URI, content, HttpWebResponse);
            'POST':
                RequestHasNoError := client.Post(URI, content, HttpWebResponse);
            'GET':
                RequestHasNoError := client.Get(URI, HttpWebResponse);
            else begin
                if XMLContent <> '' then
                    HttpWebRequest.Content := content;
                HttpWebRequest.SetRequestUri(URI);
                HttpWebRequest.Method := ActionCode;
                RequestHasNoError := client.Send(HttpWebRequest, HttpWebResponse);
            end;
        end;
        if not RequestHasNoError then begin
            Error(GetLastErrorText());
        end;
        HttpWebResponse.Content.ReadAs(ResponseInStream);
        ExtractContentFromResponse(ResponseInStream, ResponseBodyTempBlob);

    end;


    internal procedure SetNoBodyContentNeeded(LocNoBodyContentNeeded: Boolean)
    begin
        NoBodyContentNeeded := LocNoBodyContentNeeded;
    end;

    internal procedure RUNFunction(): Boolean
    begin
        CheckGlobals();
        // ++ FS
        if BasicAuthMode then begin
            if not SendRequestToWebServiceBA(GlobalRequestBodyInStream, GlobalURL, GlobalUsername, GlobalPassword, GlobalAction) then
                exit(false);
        end else begin
            // -- FS
            if not SendRequestToWebService() then
                exit(false);
        end;
        exit(true);
    end;
}