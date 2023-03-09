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
    RcvdLine    : String;
    ConnectTime : TDateTime;
  end;

  TForm1 = class(TForm)
    Button_start: TButton;
    WSocketServer1: TWSocketServer;
    Button2: TButton;
    Tcpip_Timer: TTimer;
    ListBox1: TListBox;
    Edit1: TEdit;
    Button1: TButton;
    Label1: TLabel;
    ACS_Data_1: TEdit;
    lbl1: TLabel;
    ACS_Data_2: TEdit;
    Label2: TLabel;
    ACS_Data_3: TEdit;
    Command: TLabel;
    ACS_Data_4: TEdit;
    ToNode: TLabel;
    ACS_Data_5: TEdit;
    JobID: TLabel;
    ACS_Data_6: TEdit;
    PalleteType: TLabel;
    ACS_Data_7: TEdit;
    NoneRobotSpeed1: TLabel;
    ACS_Data_8: TEdit;
    EmptyRobotSpeed: TLabel;
    ACS_Data_9: TEdit;
    FullRobotSpeed: TLabel;
    ACS_Data_10: TEdit;
    SpeedType: TLabel;
    btnAGVtoACS_SAND: TButton;
    Clear: TButton;
    procedure WSocketServer1BgException(Sender: TObject; E: Exception;
      var CanClose: Boolean);
    procedure WSocketServer1ClientConnect(Sender: TObject;
      Client: TWSocketClient; Error: Word);
    procedure WSocketServer1ClientDisconnect(Sender: TObject;
      Client: TWSocketClient; Error: Word);
    procedure Tcpip_TimerTimer(Sender: TObject);
    procedure Button_startClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAGVtoACS_SANDClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ClientDataAvailable(Sender : TObject; Error  : Word);
    procedure ClientLineLimitExceeded(Sender : TObject; Cnt : LongInt; var ClearData : Boolean);
    procedure ClientBgException(Sender : TObject; E : Exception; var CanClose : Boolean);
    procedure SendCommand(Client : TWSocketClient; Msg : String);
    //procedure sandstatus(Sender: TObject);


  end;

var
  Form1: TForm1;
  g_Start : boolean;

  // Network
  tcp_command, old_tcp_command : string;
  receive_command : array [0..5] of string;
  flag_TCP_Receive : integer;

  ClientConnect : Boolean = False;
  
  AGV_Number : array [0..3] of AnsiChar;
  AGV_X : array [0..3] of AnsiChar;
  AGV_Y : array [0..3] of AnsiChar;
  AGV_Rotate : array [0..3] of AnsiChar;
  AGV_Speed : array [0..3] of AnsiChar;
  status_divisionAddress : array [0..3] of AnsiChar;


  AGV_Number_N : string;
  AGV_X_N : string;
  AGV_Y_N : string;
  AGV_Rotate_N : string;
  AGV_Speed_N : string;
  status_divisionAddress_N : string;

  Get_ACS_Data : array [0..255,0..255] of string;


  ACS_Data_Array: array of Integer;
  temp_num: string;

  sBuf: array[1..10] of string;


  cmdAGVNUM : string;
  cmdJobID  : string;
  cmdPalleteType : string;
  cmd_count : integer;
  sBuf_log : array[1..10] of string;


implementation

{$R *.dfm}

procedure TForm1.WSocketServer1BgException(Sender: TObject; E: Exception; var CanClose: Boolean);
begin
  ListBox1.Items.Add('Server exception occured: ' + E.ClassName + ': ' + E.Message);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
  CanClose := FALSE;  { Hoping that server will still work ! }
end;

procedure TForm1.WSocketServer1ClientConnect(Sender: TObject;
  Client: TWSocketClient; Error: Word);
begin
  with Client as TTcpSrvClient do begin
    ListBox1.Items.Add('Client connected.' +
                ' Remote: ' + PeerAddr + '/' + PeerPort +
                ' Local: '  + GetXAddr + '/' + GetXPort);
    ListBox1.Items.Add('There is now ' +
                IntToStr(TWSocketServer(Sender).ClientCount) +
                ' clients connected.');
    ListBox1.ItemIndex := ListBox1.Items.Count-1;            
    LineMode            := TRUE;
    LineEdit            := TRUE;
    LineLimit           := 4096; { Do not accept long lines }
    OnDataAvailable     := ClientDataAvailable;
    OnLineLimitExceeded := ClientLineLimitExceeded;
    OnBgException       := ClientBgException;
    ConnectTime         := Now;
  end;
end;

procedure TForm1.WSocketServer1ClientDisconnect(Sender: TObject;
  Client: TWSocketClient; Error: Word);
begin
  with Client as TTcpSrvClient do begin
    ListBox1.Items.Add('Client disconnecting: ' + PeerAddr + '   ' +
                'Duration: ' + FormatDateTime('hh:nn:ss',
                Now - ConnectTime));
    ListBox1.Items.Add('There is now ' +
                IntToStr(TWSocketServer(Sender).ClientCount - 1) +
                ' clients connected.');
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end;
end;

procedure TForm1.Tcpip_TimerTimer(Sender: TObject);
begin
  if g_Start = False then exit;
end;

procedure TForm1.Button_startClick(Sender: TObject);
var
  nCount, nNodeNum : integer;
  //
  i, j, nStartPos : integer;
  sVersion, sTempNumber, sTemp : string;

begin
  g_Start   := True;
  ListBox1.Items.Add('Server Timer start');
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;

                  //////////////////////////////////////////////////////////////////////////////////
procedure TForm1.ClientDataAvailable(Sender: TObject; Error: Word);
var
  i, j, f, g: integer;
  RcvdLine, print_text : string;
  Final_cmd_print : array[1..10] of string;
  Final_cmd_print_all : string;


begin
  //cmd_count := cmd_count + 1;
  for i := 1 to 10 do
  begin
    //sBuf[i] := '';
  end;
  ACS_Data_1.Text := sBuf[1];
  ACS_Data_2.Text := sBuf[2];
  ACS_Data_3.Text := sBuf[3];
  ACS_Data_4.Text := sBuf[4];
  ACS_Data_5.Text := sBuf[5];
  ACS_Data_6.Text := sBuf[6];
  ACS_Data_7.Text := sBuf[7];
  ACS_Data_8.Text := sBuf[8];
  ACS_Data_9.Text := sBuf[9];
  ACS_Data_10.Text:= sBuf[10];



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
        ListBox1.Items.Add('[RCV] ' + print_text);
        print_text := '';
        j := j + 1;
      end
      else if RcvdLine[1] = '$' then
      begin
        if i < 2 then
        begin
          if RcvdLine ='$status' then
          begin
            ListBox1.Items.Add('[CMD] status' );
            ListBox1.ItemIndex := ListBox1.Items.Count-1;


            cmdAGVNUM := '001';
            cmdJobID  := '001';
            cmdPalleteType  := '1';

            if sBuf[1] = '' then
            begin
              for g := 1 to 10 do
              begin
                sBuf[g] := sBuf_log[g];
              end;
            end;


            if sBuf[1] = 'Ostat' then
            begin
              Final_cmd_print[1] := '상태요청';

            end
            else if sBuf[1] = 'oMove' then
            begin
              Final_cmd_print[1] := '이동 목적지(NODE) 요청';
            end
            else if sBuf[1] = 'oMore' then
            begin
              Final_cmd_print[1] := '이동 목적지(NODE) 변경 요청';
            end
            else if sBuf[1] = 'oCHAR' then
            begin
              Final_cmd_print[1] := 'Battery 충전 요청';
            end
            else if sBuf[1] = 'oLOAD' then
            begin
              Final_cmd_print[1] := 'Loading 요청';
            end
            else if sBuf[1] = 'oUNLD' then
            begin
              Final_cmd_print[1] := 'Unloading 요청';
            end
            else if sBuf[1] = 'oONLN' then
            begin
              Final_cmd_print[1] := 'Online 요청';
            end
            else if sBuf[1] = 'oJCAN' then
            begin
              Final_cmd_print[1] := 'JOB Cancel 승인';
            end
            else if sBuf[1] = 'oCANL' then
            begin
              Final_cmd_print[1] := 'Battery 충전 중지 요청';
            end
            else if sBuf[1] = 'oESTP' then
            begin
              Final_cmd_print[1] := 'AGV 정지 요청(AGV Alarm 발생)';
            end
            else if sBuf[1] = 'oFIRE' then
            begin
              Final_cmd_print[1] := 'AGV 즉시 방화셔터 구역 이외 경로로 대피 및 정지 요청';
            end
            else if sBuf[1] = 'oTP90' then
            begin
              Final_cmd_print[1] := 'AGV 90도 턴 요청';
            end
            else if sBuf[1] = 'oTP18' then
            begin
              Final_cmd_print[1] := 'AGV 180도 턴 요청';
            end
            else if sBuf[1] = 'oTM90' then
            begin
              Final_cmd_print[1] := 'AGV -90도 턴 요청';
            end
            else if sBuf[1] = 'oTM18' then
            begin
              Final_cmd_print[1] := 'AGV -180도 턴 요청';
            end
            else if sBuf[1] = 'oACSL' then
            begin
              Final_cmd_print[1] := 'ACS 가 이재기로 Loding (AGV->Vaild)';
            end
            else if sBuf[1] = 'oACSU' then
            begin
              Final_cmd_print[1] := 'ACS 가 이재기로 Unloading (AGV-> Vaild)';
            end
            else if sBuf[1] = 'oSpee' then
            begin
              Final_cmd_print[1] := 'ACS 가 AGV로 속도 제어 요청';
            end
            else if sBuf[1] = 'oPaus' then
            begin
              Final_cmd_print[1] := 'ACS 가 AGV로 Pause 요청';
            end
            else if sBuf[1] = 'oResu' then
            begin
              Final_cmd_print[1] := 'ACS 가 AGV로 Resume 요청';
            end
            else
              Final_cmd_print[1] := '/ cmd X';
            sBuf_log[1] := Final_cmd_print[1];

            if LowerCase(sBuf[2]) = 'agvnum' then
            begin
              Final_cmd_print[2] := 'AGVNUM is :' + cmdAGVNUM;
            end
            else
              Final_cmd_print[2] := 'none cmd...';
            sBuf_log[2] := Final_cmd_print[2];

            if sBuf[3] = '' then
            begin
              Final_cmd_print[3] := 'Node 정보 X';
            end
            else
              Final_cmd_print[3] := 'From ' + sBuf[3] + ' Node';
            sBuf_log[3] := Final_cmd_print[3];

            if sBuf[4] = '' then
            begin
              Final_cmd_print[4] := 'Node 정보 X';
            end
            else
              Final_cmd_print[4] := 'To ' + sBuf[4] + ' Node';
            sBuf_log[4] := Final_cmd_print[4];

            if LowerCase(sBuf[5]) = 'jobid' then
            begin
              Final_cmd_print[5] := 'JobID is : ' + cmdJobID;
            end
            else
              Final_cmd_print[5] := 'none cmd...';
            sBuf_log[5] := Final_cmd_print[5];

            if LowerCase(sBuf[6]) = 'pallete type' then
            begin
              Final_cmd_print[6] := 'Pallete Type is : ' + cmdPalleteType;
            end
            else
              Final_cmd_print[6] := 'none cmd...';
            sBuf_log[6] := Final_cmd_print[6];


            Final_cmd_print[7] := 'none speed data';
            sBuf_log[7] := Final_cmd_print[7];

            Final_cmd_print[8] := 'none speed data';
            sBuf_log[8] := Final_cmd_print[8];

            Final_cmd_print[9] := 'none speed data';
            sBuf_log[9] := Final_cmd_print[9];

            Final_cmd_print[10]:= 'none speed data';
            sBuf_log[10] := Final_cmd_print[10];


            //Final_cmd_print_all := Final_cmd_print[1] + '/ ' + Final_cmd_print[2] + '/ ' + Final_cmd_print[3] + '/ ' + Final_cmd_print[4] + '/ ' + Final_cmd_print[5] + '/ ' + Final_cmd_print[6] + '/ ' + Final_cmd_print[7] + '/ ' + Final_cmd_print[8] + '/ ' + Final_cmd_print[9] + '/ ' + Final_cmd_print[10];

            Final_cmd_print_all := '';
            for g := 1 to 10 do
            begin
              Final_cmd_print_all := Final_cmd_print_all + Final_cmd_print[g] + '/ ';
            end;
            Final_cmd_print_all := IntToStr(cmd_count-1) + '/' + Final_cmd_print_all;
            SendCommand( WSocketServer1.Client[0] , Final_cmd_print_all);
            //ListBox1.Items.Add(Final_cmd_print_all);
            ListBox1.ItemIndex := ListBox1.Items.Count-1;








          end
          else
          if RcvdLine ='$start' then
          begin
            //AGV_move_speed := AGV_move_speed + 100;
            SendCommand( WSocketServer1.Client[0] , 'AGV start');
            ListBox1.Items.Add('');
            ListBox1.ItemIndex := ListBox1.Items.Count-1;
          end
          else
          ListBox1.Items.Add(' Warning : wrong command');
          ListBox1.ItemIndex := ListBox1.Items.Count-1;
        end;
        //ListBox1.Items.Add(print_text);
      //ListBox1.ItemIndex := ListBox1.Items.Count-1;
      end
      else
      begin
        print_text := print_text + RcvdLine[i];
        sBuf[j] := print_text;
        ACS_Data_1.Text := sBuf[1];
        ACS_Data_2.Text := sBuf[2];
        ACS_Data_3.Text := sBuf[3];
        ACS_Data_4.Text := sBuf[4];
        ACS_Data_5.Text := sBuf[5];
        ACS_Data_6.Text := sBuf[6];
        ACS_Data_7.Text := sBuf[7];
        ACS_Data_8.Text := sBuf[8];
        ACS_Data_9.Text := sBuf[9];
        ACS_Data_10.Text := sBuf[10];
      end;
    end;
    if print_text <> '' then
      ListBox1.Items.Add('[RCV] ' + print_text);
      ListBox1.ItemIndex := ListBox1.Items.Count-1;

  end;







  {
  for i := 1 to 10 do
  begin
    sBuf[i] := '';
  end;
  } //Don't reset


  cmd_count := cmd_count + 1;
end;

       /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{
procedure TForm1.ClientDataAvailable(Sender : TObject; Error  : Word);
Label GO_EXIT;

var
  temp_count, i, j : integer;
  a, x, y : integer;
  print_text : string;
begin
  j := 0;
  if g_Start <> True then exit;

  with Sender as TTcpSrvClient do
  begin
    // We use line mode. We will receive complete lines
    RcvdLine := ReceiveStr();
    print_text := ReceiveStr();
    // Remove trailing CR/LF
    while (Length(RcvdLine) > 0) and (RcvdLine[Length(RcvdLine)] in [#13, #10]) do
      RcvdLine := Copy(RcvdLine, 1, Length(RcvdLine) - 1);

    i := 1;
    j := 1;
    for i := 1 to Length(RcvdLine) do
    begin
      if RcvdLine[i] = '/' then
      begin
        Get_ACS_Data[i,j] := '/';
        j := j+1;
      end
      else
        Get_ACS_Data[i,j] := RcvdLine[i];
    end;

    i := 1;
    j := 1;
    for i := 1 to Length(RcvdLine) do
    begin
      if RcvdLine[i] = '/' then
      begin
        Get_ACS_Data[i,j] := '/';
        j := j+1;
      end
      else
      begin
        Get_ACS_Data[i,j] := RcvdLine[i];
        print_text := Concat(print_text, RcvdLine[i]);
        ListBox1.Items.Add(Get_ACS_Data[i,j]) ;
        ListBox1.ItemIndex := ListBox1.Items.Count-1;
      end;
    end;

    ListBox1.Items.Add('[rcv] ' + print_text) ;
    ListBox1.ItemIndex := ListBox1.Items.Count-1;

  end;
end;




   {
procedure TForm1.ClientDataAvailable(Sender : TObject; Error  : Word);
Label GO_EXIT;
var
  temp_count : integer;
begin

  with Sender as TTcpSrvClient do begin
    // We use line mode. We will receive complete lines
    RcvdLine := ReceiveStr();

    // Remove trailing CR/LF
    while (Length(RcvdLine) > 0) and
          //(RcvdLine[Length(RcvdLine)] in [#65]) do
          (RcvdLine[Length(RcvdLine)] in [#13, #10]) do
           RcvdLine := Copy(RcvdLine, 1, Length(RcvdLine) - 1);
    //
    ListBox1.Items.Add('[rcv] ' + RcvdLine);
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end;
  //ACStoAGV_SANDClick();
  //ACS_Data_1.Text := '123'
end;
      }



















{
procedure TForm1.ClientDataAvailable(Sender: TObject; Error: Word);
var
  temp_count, i: integer;
  temp_num: string;
begin
  if not g_Start then Exit;

  with Sender as TTcpSrvClient do begin
    RcvdLine := ReceiveStr();

    while Length(RcvdLine) > 0 do begin
      // Remove trailing CR/LF
      while (Length(RcvdLine) > 0) and (RcvdLine[Length(RcvdLine)] in [#13, #10]) do
        RcvdLine := Copy(RcvdLine, 1, Length(RcvdLine) - 1);

      // Extract each number separated by '/'
      temp_count := 0;
      while (Length(RcvdLine) > 0) and (RcvdLine[1] in ['0'..'9']) do begin
        temp_num := '';
        while (Length(RcvdLine) > 0) and (RcvdLine[1] in ['0'..'9']) do begin
          temp_num := temp_num + RcvdLine[1];
          Delete(RcvdLine, 1, 1);
        end;
        if Length(temp_num) > 0 then begin
          Inc(temp_count);
          SetLength(ACS_Data_Array, temp_count);
          ACS_Data_Array[temp_count-1] := StrToInt(temp_num);
        end;
        if Length(RcvdLine) > 0 then
          Delete(RcvdLine, 1, 1); // Remove '/'
      end;

      // Display received line in ListBox
      if temp_count > 0 then begin
        ListBox1.Items.Add('[rcv] ' + IntToStr(ACS_Data_Array[0]));
        for i := 1 to temp_count-1 do
          ListBox1.Items.Add('[rcv] ' + IntToStr(ACS_Data_Array[i]));
        ListBox1.ItemIndex := ListBox1.Items.Count-1;
      end else begin
        ListBox1.Items.Add('[rcv] ' + RcvdLine);
        ListBox1.ItemIndex := ListBox1.Items.Count-1;
      end;
    end;
  end;
end;
}


procedure TForm1.ClientLineLimitExceeded(Sender : TObject; Cnt : LongInt; var ClearData : Boolean);
begin
  with Sender as TTcpSrvClient do begin
    ListBox1.Items.Add('Line limit exceeded from ' + GetPeerAddr + '. Closing.');
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
    ClearData := TRUE;
    Close;
  end;
end;

procedure TForm1.ClientBgException(Sender : TObject; E : Exception; var CanClose : Boolean);
begin
    ListBox1.Items.Add('Client exception occured: ' + E.ClassName + ': ' + E.Message);
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
    CanClose := TRUE;   { Goodbye client ! }
end;

procedure TForm1.SendCommand(Client : TWSocketClient; Msg : String);
begin
  Client.SendStr(Msg + Chr(13) + Chr(10));
  ListBox1.Items.Add('[snd] ' + Msg);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  i, j, nStartPos, nCount : integer;
  SysMenu: HMENU;
  sFileName, sTemp, sTempNumber, sVersion : string;
  nTemp : Integer;
begin
  // #. Socket Set
  WSocketServer1.Proto       := 'tcp';         { Use TCP protocol  }
  WSocketServer1.Port        := '1001';//'telnet';      { Use telnet port   }
  WSocketServer1.Addr        := '127.0.0.1'; //'0.0.0.0';     { Use any interface }
  WSocketServer1.ClientClass := TTcpSrvClient; { Use our component }
  WSocketServer1.Listen;                       { Start litening    }
  ListBox1.Items.Add ('Waiting for clients...');
  ListBox1.ItemIndex := ListBox1.Items.Count-1;

  g_Start   := False;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  tClient : TTcpSrvClient;
begin

  SendCommand( WSocketServer1.Client[0] , Edit1.text);
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



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 {
procedure TForm1.sandstatus(Sender: TObject);
var
  i : integer;
  AGVstatus : string;
begin

  AGVstatus := '';
  for i := 1 to length(status_divisionAddress)*5 do
  begin
    if (i+4) mod 5 = 0 then
    begin
      AGVstatus[i-1] := '/'
    end else
    begin
      AGVstatus[i] := AGV_Number[i];
      AGVstatus[i+5] := AGV_X[i+5];
      AGVstatus[i+10] := AGV_Y[i+10];
      AGVstatus[i+15] := AGV_Rotate[i+15];
      AGVstatus[i+20] := AGV_Speed[i+20];
    end;
  end;
  WSocket1.SendStr(AGVstatus);
  ListBox1.Items.Add( '[SND] ' + AGVstatus);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;

    
procedure TForm1.makingstatus(Sender: TObject);
var
  MAX_DIGITS = 5;
  //inputstatus: array[1..length(status_divisionAddress), 1..MAX_DIGITS] of integer;
  outputstatus: array[1..length(status_divisionAddress), 1..MAX_DIGITS] of integer;
  i,j,k,num : integer;
begin
  status := '';

  AGV_Number_N := AGV_Number
  AGV_X_N := AGV_X
  AGV_Y_N := AGV_Y
  AGV_Rotate_N := AGV_Rotate
  AGV_Speed_N := AGV_Speed
  status_divisionAddress_N := status_divisionAddress

  for j := 1 to length(vstatus_divisionAddress_N+1) do
  begin
    if outputstatus[j] = '/' then
    begin
      num := num + 1;
      i := 1;
    end
    else
    begin
      outputstatus[num, i] := ord(AGV_Number[j]) - ord('0');



      i := i + 1;
    end;
  end;


  for i := 1 to 5 do
  begin
    writeln('/', i, AGV_Number[i]);
  end;

  {
  for i := 1 to length(status_divisionAddress*5) do
  begin
    if (i+4) mod 5 = 0 then
    begin
      status[i-1] := '/'
    end else
    begin
      status[i] := AGV_Number[i];
      status[i+5] := AGV_X[i+5];
      status[i+10] := AGV_Y[i+10];
      status[i+15] := AGV_Rotate[i+15];
      status[i+20] := AGV_Speed[i+20];
    end;
  end;
  }




procedure TForm1.btnAGVtoACS_SANDClick(Sender: TObject);
var
  q : integer;
  SandStatus1: string;
begin
  sBuf[1] := ACS_Data_1.Text;
  sBuf[2] := ACS_Data_2.Text;
  sBuf[3] := ACS_Data_3.Text;
  sBuf[4] := ACS_Data_4.Text;
  sBuf[5] := ACS_Data_5.Text;
  sBuf[6] := ACS_Data_6.Text;
  sBuf[7] := ACS_Data_7.Text;
  sBuf[8] := ACS_Data_8.Text;
  sBuf[9] := ACS_Data_9.Text;
  sBuf[10]:= ACS_Data_10.Text;

  SandStatus1 :=  '';
  for q := 1 to 10 do
  begin
    SandStatus1 :=  SandStatus1+sBuf[q]+'/';
  end;
  SandStatus1 := Copy(SandStatus1, 1, Length(SandStatus1) - 1);
  //WSocket1.SendStr(SandStatus1);
  ListBox1.Items.Add( '[SND] '+SandStatus1);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
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
