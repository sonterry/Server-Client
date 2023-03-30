unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OverbyteIcsWndControl, OverbyteIcsWSocket, OverbyteIcsWSocketS,
  StdCtrls, ExtCtrls;

type
  // Receive Message data
  TTcpSrvClient = class(TWSocketClient)
  public
    RcvdLine: string;
    ConnectTime: TDateTime;
  end;

  TForm1 = class(TForm)
    Button_start: TButton;
    WSocketServer1: TWSocketServer;
    Button1: TButton;
    Button2: TButton;
    Tcpip_Timer: TTimer;
    ListBox1: TListBox;
    Edit1: TEdit;
    Command: TLabel;
    ToNode: TLabel;
    JobID: TLabel;
    PalleteType: TLabel;
    NoneRobotSpeed1: TLabel;
    EmptyRobotSpeed: TLabel;
    FullRobotSpeed: TLabel;
    SpeedType: TLabel;
    Clear: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    Label2: TLabel;
    ACS_Data_1: TEdit;
    ACS_Data_2: TEdit;
    ACS_Data_3: TEdit;
    ACS_Data_4: TEdit;
    ACS_Data_5: TEdit;
    ACS_Data_6: TEdit;
    ACS_Data_7: TEdit;
    ACS_Data_9: TEdit;
    ACS_Data_8: TEdit;
    ACS_Data_10: TEdit;
    ACS_Data_11: TEdit;
    ACS_Data_12: TEdit;
    ACS_Data_13: TEdit;
    ACS_Data_14: TEdit;
    ACS_Data_15: TEdit;
    ACS_Data_16: TEdit;
    ACS_Data_17: TEdit;
    ACS_Data_18: TEdit;
    ACS_Data_19: TEdit;
    ACS_Data_20: TEdit;
    ACS_Data_21: TEdit;
    procedure WSocketServer1BgException(Sender: TObject; E: Exception; var CanClose: Boolean);
    procedure WSocketServer1ClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure WSocketServer1ClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure Tcpip_TimerTimer(Sender: TObject);
    procedure Button_startClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    //procedure btnAGVtoACS_SANDClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    //procedure lbl1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ClientDataAvailable(Sender: TObject; Error: Word);
    procedure ClientLineLimitExceeded(Sender: TObject; Cnt: LongInt; var ClearData: Boolean);
    procedure ClientBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
    procedure SendCommand(Client: TWSocketClient; Msg: string);
    //procedure sandstatus(Sender: TObject);

  end;

var
  Form1: TForm1;
  g_Start: boolean;

  // Network
  tcp_command, old_tcp_command: string;
  receive_command: array[0..5] of string;
  flag_TCP_Receive: integer;
  ClientConnect: Boolean = False;
  AGV_Number: array[0..3] of AnsiChar;
  AGV_X: array[0..3] of AnsiChar;
  AGV_Y: array[0..3] of AnsiChar;
  AGV_Rotate: array[0..3] of AnsiChar;
  AGV_Speed: array[0..3] of AnsiChar;
  status_divisionAddress: array[0..3] of AnsiChar;
  AGV_Number_N: string;
  AGV_X_N: string;
  AGV_Y_N: string;
  AGV_Rotate_N: string;
  AGV_Speed_N: string;
  status_divisionAddress_N: string;
  Get_ACS_Data: array[0..255, 0..255] of string;
  ACS_Data_Array: array of Integer;
  temp_num: string;
  sBuf: array[1..21] of string;
  cmdAGVNUM: string;
  cmdJobID: string;
  cmdPalleteType: string;
  cmd_count: integer;
  sBuf_log: array[1..21] of string;
  cmd_count_print: string;

implementation

{$R *.dfm}

procedure TForm1.WSocketServer1BgException(Sender: TObject; E: Exception; var CanClose: Boolean);
begin
  ListBox1.Items.Add('Server exception occured: ' + E.ClassName + ': ' + E.Message);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  CanClose := FALSE;  { Hoping that server will still work ! }
end;

procedure TForm1.WSocketServer1ClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
begin
  with Client as TTcpSrvClient do
  begin
    ListBox1.Items.Add('Client connected.' + ' Remote: ' + PeerAddr + '/' + PeerPort + ' Local: ' + GetXAddr + '/' + GetXPort);
    ListBox1.Items.Add('There is now ' + IntToStr(TWSocketServer(Sender).ClientCount) + ' clients connected.');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
    LineMode := TRUE;
    LineEdit := TRUE;
    LineLimit := 4096; { Do not accept long lines }
    OnDataAvailable := ClientDataAvailable;
    OnLineLimitExceeded := ClientLineLimitExceeded;
    OnBgException := ClientBgException;
    ConnectTime := Now;
  end;
end;

procedure TForm1.WSocketServer1ClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
begin
  with Client as TTcpSrvClient do
  begin
    ListBox1.Items.Add('Client disconnecting: ' + PeerAddr + '   ' + 'Duration: ' + FormatDateTime('hh:nn:ss', Now - ConnectTime));
    ListBox1.Items.Add('There is now ' + IntToStr(TWSocketServer(Sender).ClientCount - 1) + ' clients connected.');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end;
end;

procedure TForm1.Tcpip_TimerTimer(Sender: TObject);
begin
  if g_Start = False then
    exit;
end;

procedure TForm1.Button_startClick(Sender: TObject);
var
  nCount, nNodeNum: integer;
  //
  i, j, nStartPos: integer;
  sVersion, sTempNumber, sTemp: string;
begin
  g_Start := True;
  ListBox1.Items.Add('Server Timer start');
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
end;


   
                  //////////////////////////서버////////////////////////////////////////////////////////
procedure TForm1.ClientDataAvailable(Sender: TObject; Error: Word);
var
  i, j, t: integer;
  RcvdLine, print_text: string;
  Final_cmd_print: array[1..21] of string;
  Final_cmd_print_all: string;
  processed_RcvdLine: string;
  //beforeNode : string;

begin
  cmd_count_print := IntToStr(cmd_count);
  //beforeNode := '0000';
  for i := 1 to 21 do
  begin
    sBuf[i] := '';
  end;

  sBuf[1] := ACS_Data_1.Text;
  sBuf[2] := ACS_Data_2.Text;
  sBuf[3] := ACS_Data_3.Text;
  sBuf[4] := ACS_Data_4.Text;
  sBuf[5] := ACS_Data_5.Text;
  sBuf[6] := ACS_Data_6.Text;
  sBuf[7] := ACS_Data_7.Text;
  sBuf[8] := ACS_Data_8.Text;
  sBuf[9] := ACS_Data_9.Text;
  sBuf[10] := ACS_Data_10.Text;
  sBuf[11] := ACS_Data_11.Text;
  sBuf[12] := ACS_Data_12.Text;
  sBuf[13] := ACS_Data_13.Text;
  sBuf[14] := ACS_Data_14.Text;
  sBuf[15] := ACS_Data_15.Text;
  sBuf[16] := ACS_Data_16.Text;
  sBuf[17] := ACS_Data_17.Text;
  sBuf[18] := ACS_Data_18.Text;
  sBuf[19] := ACS_Data_19.Text;
  sBuf[20] := ACS_Data_20.Text;
  sBuf[21] := ACS_Data_21.Text;

  cmdAGVNUM := '001';
  cmdJobID := '001';
  cmdPalleteType := '1';

  if not g_Start then
    Exit;

  with Sender as TTcpSrvClient do
  begin
    // We use line mode. We will receive complete lines
    RcvdLine := ReceiveStr();
    // Remove trailing CR/LF
    while (Length(RcvdLine) > 0) and (RcvdLine[Length(RcvdLine)] in [#13, #10]) do
      RcvdLine := Copy(RcvdLine, 1, Length(RcvdLine) - 1);

    print_text := '';
    j := 1;
    for i := 1 to Length(RcvdLine) do
    begin
      if RcvdLine[i] = '/' then
      begin

        print_text := '';
        j := j + 1;
      end
      else if (Copy(RcvdLine, 6, 1) = 'o') or (Copy(RcvdLine, 1, 1) = 'o') then
      begin
        if i < 2 then
        begin
          if Copy(RcvdLine, 1, 1) = 'o' then
          begin
            if Length(cmd_count_print) = 1 then
            begin
              cmd_count_print := '000' + IntToStr(cmd_count);
            end
            else if Length(cmd_count_print) = 2 then
            begin
              cmd_count_print := '00' + IntToStr(cmd_count);
            end
            else if Length(cmd_count_print) = 3 then
            begin
              cmd_count_print := '0' + IntToStr(cmd_count);
            end;
          end
          else if Copy(RcvdLine, 6, 1) = 'o' then
          begin
            Final_cmd_print[1] := 'aSTAT';
            if Length(cmd_count_print) = 1 then
            begin
              cmd_count_print := '000' + IntToStr(cmd_count);
            end
            else if Length(cmd_count_print) = 2 then
            begin
              cmd_count_print := '00' + IntToStr(cmd_count);
            end
            else if Length(cmd_count_print) = 3 then
            begin
              cmd_count_print := '0' + IntToStr(cmd_count);
            end;
          end;
          processed_RcvdLine := cmd_count_print + '/' + RcvdLine;
        end;
      end
      else
      begin
        print_text := print_text + RcvdLine[i];
        sBuf[j] := print_text;
      end;
    end;

    if Copy(processed_RcvdLine, 12, 4) <> '0000' then
    begin
      ACS_Data_11.Text := Copy(processed_RcvdLine, 12, 4);
    end;
    if Copy(processed_RcvdLine, 17, 4) <> '0000' then
    begin
      ACS_Data_12.Text := Copy(processed_RcvdLine, 17, 4);
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oSTAT' then
    begin
      Final_cmd_print[1] := 'aSTAT';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oMOVE' then
    begin
      if Copy(processed_RcvdLine, 12, 4) <> Copy(processed_RcvdLine, 17, 4) then
      begin
        ACS_Data_8.Text := '1';  //Moving
        ACS_Data_9.Text := '600';
        Final_cmd_print[1] := 'aMOVE';
      end
      else if Copy(processed_RcvdLine, 12, 4) = Copy(processed_RcvdLine, 17, 4) then
      begin

        ACS_Data_8.Text := '0';  //Idle
        ACS_Data_9.Text := '0';
        ListBox1.Items.Add('Now Node is ' + Copy(processed_RcvdLine, 12, 4) + '    To Node is ' + Copy(processed_RcvdLine, 17, 4));     //Node 확인용
        ListBox1.Items.Add('[WARNING] Now Node and To Node is same');
        SendCommand(WSocketServer1.Client[0], '[WARNING] Now Node and To Node is same');
        ListBox1.ItemIndex := ListBox1.Items.Count - 1;
      end;
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oMORE' then
    begin
      Final_cmd_print[1] := 'aMORE';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oCHAR' then
    begin
      Final_cmd_print[1] := 'aCHAR';
      ACS_Data_8.Text := '4';
      ACS_Data_9.Text := '0';
      ACS_Data_10.Text := '0000';
      ACS_Data_12.Text := '1001';
      if Copy(processed_RcvdLine, 17, 4) <> '1001' then
      begin
        SendCommand(WSocketServer1.Client[0], Copy(processed_RcvdLine, 17, 4) + ' is not CHARGE Node');
        Final_cmd_print[1] := 'cCHAR';
        ACS_Data_8.Text := '2';
        ACS_Data_9.Text := '0';
        ACS_Data_10.Text := '3018';
      end;
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oLOAD' then
    begin
      Final_cmd_print[1] := 'aLOAD';
      ACS_Data_8.Text := '5';
      ACS_Data_10.Text := '0000';
      ACS_Data_12.Text := '1007';
      if Copy(processed_RcvdLine, 17, 4) <> '1007' then
      begin
        SendCommand(WSocketServer1.Client[0], Copy(processed_RcvdLine, 17, 4) + ' is not LOAD Node');
        ACS_Data_8.Text := '2';
        ACS_Data_9.Text := '0';
        ACS_Data_10.Text := '2001';
      end;
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oUNLD' then
    begin
      Final_cmd_print[1] := 'aUNLD';
      ACS_Data_8.Text := '6';
      ACS_Data_10.Text := '0000';
      ACS_Data_12.Text := '1006';
      if Copy(processed_RcvdLine, 17, 4) <> '1006' then
      begin
        SendCommand(WSocketServer1.Client[0], Copy(processed_RcvdLine, 17, 4) + ' is not UNLOAD Node');
        ACS_Data_8.Text := '2';
        ACS_Data_9.Text := '0';
        ACS_Data_10.Text := '2001';
      end;
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oJCAN' then
    begin
      Final_cmd_print[1] := 'aJCAN';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oCANL' then
    begin
      Final_cmd_print[1] := 'aCANL';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oESTP' then
    begin
      Final_cmd_print[1] := 'aESTP';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oFIRE' then
    begin
      Final_cmd_print[1] := 'aFIRE';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oTP90' then
    begin
      Final_cmd_print[1] := 'aTP90';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oTP18' then
    begin
      Final_cmd_print[1] := 'aTP18';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oTM90' then
    begin
      Final_cmd_print[1] := 'aTM90';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oTM18' then
    begin
      Final_cmd_print[1] := 'aTM18';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oACSL' then
    begin
      Final_cmd_print[1] := 'aACSL';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oACSU' then
    begin
      Final_cmd_print[1] := 'aACSU';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oSpee' then
    begin
      Final_cmd_print[1] := 'aSpee';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oPaus' then
    begin
      Final_cmd_print[1] := 'aPaus';
      ACS_Data_8.Text := '3';
      ACS_Data_9.Text := '0';
    end;

    if Copy(processed_RcvdLine, 6, 5) = 'oResu' then
    begin
      Final_cmd_print[1] := 'aResu';
      ACS_Data_8.Text := '9';
      ACS_Data_9.Text := '600';
    end;

    if Copy(processed_RcvdLine, 12, 4) = Copy(processed_RcvdLine, 17, 4)then    //From 과 TO가 같습니다.
    begin
      Final_cmd_print[1] := '0009';
      ACS_Data_8.Text := '3';
      ACS_Data_9.Text := '0';
    end;





























    Final_cmd_print[2] := ACS_Data_2.Text;
    Final_cmd_print[3] := ACS_Data_3.Text;
    Final_cmd_print[4] := ACS_Data_4.Text;
    Final_cmd_print[5] := ACS_Data_5.Text;
    Final_cmd_print[6] := ACS_Data_6.Text;
    Final_cmd_print[7] := ACS_Data_7.Text;
    Final_cmd_print[8] := ACS_Data_8.Text;
    Final_cmd_print[9] := ACS_Data_9.Text;
    Final_cmd_print[10] := ACS_Data_10.Text;
    Final_cmd_print[11] := ACS_Data_11.Text;
    Final_cmd_print[12] := ACS_Data_12.Text;
    Final_cmd_print[13] := ACS_Data_13.Text;
    Final_cmd_print[14] := ACS_Data_14.Text;
    Final_cmd_print[15] := ACS_Data_15.Text;
    Final_cmd_print[16] := ACS_Data_16.Text;
    Final_cmd_print[17] := ACS_Data_17.Text;
    Final_cmd_print[18] := ACS_Data_18.Text;
    Final_cmd_print[19] := ACS_Data_19.Text;
    Final_cmd_print[20] := ACS_Data_20.Text;
    Final_cmd_print[21] := ACS_Data_21.Text;
    Final_cmd_print_all := '';
    for t := 1 to 21 do
    begin
      Final_cmd_print_all := Final_cmd_print_all + Final_cmd_print[t] + '/';
    end;
    Final_cmd_print_all := cmd_count_print + '/' + Final_cmd_print_all;
    Final_cmd_print_all := Copy(Final_cmd_print_all, 1, Length(Final_cmd_print_all) - 1);
    ListBox1.Items.Add('[RCV] ' + processed_RcvdLine);
    SendCommand(WSocketServer1.Client[0], Final_cmd_print_all);
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end;
  cmd_count := cmd_count + 1;
end;






procedure TForm1.ClientLineLimitExceeded(Sender: TObject; Cnt: LongInt; var ClearData: Boolean);
begin
  with Sender as TTcpSrvClient do
  begin
    ListBox1.Items.Add('Line limit exceeded from ' + GetPeerAddr + '. Closing.');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
    ClearData := TRUE;
    Close;
  end;
end;

procedure TForm1.ClientBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
begin
  ListBox1.Items.Add('Client exception occured: ' + E.ClassName + ': ' + E.Message);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  CanClose := TRUE;   { Goodbye client ! }
end;

procedure TForm1.SendCommand(Client: TWSocketClient; Msg: string);
begin
  Client.SendStr(Msg + Chr(13) + Chr(10));
  ListBox1.Items.Add('[snd] ' + Msg);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, j, nStartPos, nCount: integer;
  SysMenu: HMENU;
  sFileName, sTemp, sTempNumber, sVersion: string;
  nTemp: Integer;
begin
  // #. Socket Set
  WSocketServer1.Proto := 'tcp';         { Use TCP protocol  }
  WSocketServer1.Port := '1001'; //'telnet';      { Use telnet port   }
  WSocketServer1.Addr := '127.0.0.21'; //'0.0.0.0';     { Use any interface }
  WSocketServer1.ClientClass := TTcpSrvClient; { Use our component }
  WSocketServer1.Listen;                       { Start litening    }
  ListBox1.Items.Add('Waiting for clients...');
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;

  g_Start := False;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  tClient: TTcpSrvClient;
begin

  SendCommand(WSocketServer1.Client[0], Edit1.text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  g_Start := False;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tcpip_Timer.Enabled := False;
  WSocketServer1.Close;
end;


procedure TForm1.ClearClick(Sender: TObject);
begin
  ListBox1.Clear;
  Edit1.Text := '';
  ACS_Data_1.Text := '';
  ACS_Data_2.Text := '';
  ACS_Data_3.Text := '';
  ACS_Data_4.Text := '';
  ACS_Data_5.Text := '';
  ACS_Data_6.Text := '';
  ACS_Data_7.Text := '';
  ACS_Data_8.Text := '';
  ACS_Data_9.Text := '';
  ACS_Data_10.Text := '';
end;

end.
