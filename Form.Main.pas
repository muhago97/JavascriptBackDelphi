unit Form.Main;

interface

uses
  System.Types, System.Classes, FGX.Forms, FGX.Forms.Types, FGX.Controls, FGX.Controls.Types, FGX.Layout,
  FGX.Layout.Types, FGX.Button.Types, FGX.Button, FGX.WebBrowser, FGX.Memo, Androidapi.JNIBridge,
  Androidapi.JNI.Webkit,Androidapi.Helpers, Androidapi.JNI.JavaTypes;

type
  TFormMain = class(TfgForm)
    fgWebBrowser1: TfgWebBrowser;
    fgButton1: TfgButton;
    fgMemo1: TfgMemo;
    fgMemo2: TfgMemo;
    procedure fgButton1Tap(Sender: TObject);
    procedure fgFormCreate(Sender: TObject);
  private
    FInterfaceObj: JObject;
    FWebView: JWebView;
    FClient: JWebChromeClient;
  public
    { Public declarations }
  end;

    TAndroidWebViewInterface = class(TJavaLocal, Androidapi.JNI.Webkit.JJavascriptInterface)
  private
    [weak] FForm: TFormMain;
  public
    constructor Create(AForm: TFormMain);
    procedure ConsoleMessage(Msg: JString); cdecl;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.xfm}

{ TAndroidWebViewInterface }

constructor TAndroidWebViewInterface.Create(AForm: TFormMain);
begin
  inherited Create;
  FForm := AForm;
end;

procedure TAndroidWebViewInterface.ConsoleMessage(Msg: JString);
var
  LMsg: string;
begin
  LMsg := JStringToString(Msg);
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FForm) then
        FForm.fgMemo1.Lines.Add(lMsg);
    end);
end;

{ TFormMain }

procedure TFormMain.fgButton1Tap(Sender: TObject);
begin
  fgWebBrowser1.EvaluateJavascript('window.MyClient.ConsoleMessage("Hello, World!");');
end;

procedure TFormMain.fgFormCreate(Sender: TObject);
var
  LSettings: JWebSettings;
begin
  FWebView := TJWebView.JavaClass.init(SharedActivity);
  FClient := TJWebChromeClient.JavaClass.init;
  FInterfaceObj := TAndroidWebViewInterface.Create(Self);
  LSettings := FWebView.getSettings();
  LSettings.setJavaScriptEnabled(True);
  LSettings.setDomStorageEnabled(True);
  LSettings.setAllowFileAccess(True);
  FWebView.setWebChromeClient(FClient);
  FWebView.addJavascriptInterface(FInterfaceObj, StringToJString('MyClient'));

end;

end.

