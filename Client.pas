unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OverbyteIcsWndControl, OverbyteIcsWSocket, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    WSocket1: TWSocket;
    ListBox1: TListBox;
    Button3: TButton;
    Edit_Chat: TEdit;
    Label1: TLabel;
    Button4: TButton;
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
    ACStoAGV_SAND: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WSocket1SessionConnected(Sender: TObject; ErrCode: Word);
    procedure WSocket1SessionClosed(Sender: TObject; ErrCode: Word);
    procedure WSocket1DataAvailable(Sender: TObject; ErrCode: Word);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    //procedure SandStatus(Sender: TObject);
    procedure ACStoAGV_SANDClick(Sender: TObject);
    procedure change123(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Buffer  : array [0..1023] of AnsiChar; // Socket Receive로 활용
  status  : array [0..1023] of AnsiChar;
  i,j,k,word_count : Integer;
  AGV_Number : array [0..3] of AnsiChar;
  AGV_X : array [0..3] of AnsiChar;
  AGV_Y : array [0..3] of AnsiChar;
  AGV_Rotate : array [0..3] of AnsiChar;
  AGV_Speed : array [0..3] of AnsiChar;
  status_divisionAddress : array [0..3] of AnsiChar;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  sLog : string;
begin

  if (WSocket1.State <> wsConnected) then // 연결되지 않았다면
  begin
    { Not connected yet, start connection }
    try
      try
        with WSocket1 do
        begin
          Proto    := 'tcp';
          Port     := '1001';
          Addr     := '127.0.0.1';
          LineMode := TRUE;
          LineEnd  := #13#10;
          //Name     := 'AGV01'; // ex) IndyClient[0], IndyClient[1] ...
          Tag      := 0;
        end;
        WSocket1.Connect;
      except
        //
        WSocket1.Close;
      end;
    Finally
      if WSocket1.State = wsClosed then
      begin
        WSocket1.Connect;
      end;
    end;

    { Connect is asynchronous (non-blocking). When the session is  }
    { connected (or fails to), we have an OnSessionConnected event }
    { This is where actual sending of data is done.                }
     ListBox1.Items.Add('Waiting to host...');
     ListBox1.ItemIndex := ListBox1.Items.Count-1;

  end else
  begin
    Application.messagebox(PChar('이미 Socket이 연결되어 있습니다.'), 'WARNING', MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  sLog : string;
begin
  if (WSocket1.State <> wsConnected) then
  begin
    Application.messagebox(PChar('이미 Socket연결이 끊어져 있는 상태입니다.'), 'WARNING', MB_OK or MB_ICONINFORMATION);
    Exit;
  end else
  begin
    try
      WSocket1.Close;
      //
      //INIT_AGV_Infomation(_nAGVNum);
    except
      //
    end;

    ListBox1.Items.Add('disconnected to host...');
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end;
end;

procedure TForm1.WSocket1SessionConnected(Sender: TObject; ErrCode: Word);
var
  i : integer;
  sLog : string;
begin
  if ErrCode <> 0 then
  begin
    ListBox1.Items.Add('@ Can''t connect, error #' + IntToStr(ErrCode));
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end else
  begin
    ListBox1.Items.Add( 'AGVConnected');
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end;
end;

procedure TForm1.WSocket1SessionClosed(Sender: TObject; ErrCode: Word);
begin
  if ErrCode <> 0 then
  begin
    ListBox1.Items.Add('Disconnected, error #' + IntToStr(ErrCode));
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end else
  begin
    ListBox1.Items.Add('Disconnected');
    ListBox1.ItemIndex := ListBox1.Items.Count-1;
  end;
  //AGV1_Connect_Request := true;
end;

procedure TForm1.WSocket1DataAvailable(Sender: TObject; ErrCode: Word);
var
  nCount, Len, i : Integer;
  sTemp : string;
begin

  { We use line mode, we will receive a complete line }
  Len := WSocket1.Receive(@Buffer, SizeOf(Buffer) - 1);

  Buffer[Len] := #0; { Nul terminate  }
  for i := 0 to 4096 do
  begin
    if (Buffer[i] = #13) or (Buffer[i] = #10) then
    begin
      Break;
    end else
    begin
      sTemp := sTemp + Buffer[i];
    end;
  end;

  ListBox1.Items.Add( '[RCV] ' + sTemp);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  command, sBuf : string;
begin
  // WRITE
  sBuf := Edit_Chat.Text + Chr(13) + Chr(10);
  WSocket1.SendStr(sBuf);
  ListBox1.Items.Add( '[SND] ' + sBuf);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ListBox1.Clear;
  Edit_Chat.Text := '';
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


{
procedure TForm1.SandStatus(Sender: TObject);
var
  i : integer;
begin
  status := '';
  for i := 1 to Length(status_divisionAddress)*5 do
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
  WSocket1.SendStr(status);
  ListBox1.Items.Add( '[SND] ' + status);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;
}















  {
  for i := 1 to length(status_divisionAddress){or data 갯수}{ do
  begin
    word_count := k + 1;
    if

    status := status + Format('%03d', [word_count]);
  end;


  for i := 1 to length(status_divisionAddress) do
  begin
    for j := 1 to 4 do
    begin
      if (i - 1) * 3 + j <= length(status_divisionAddress) then
        status := status + '/ ' + status_divisionAddress[(i - 1) * 3 + j]
      else
        status := status + '/  ';
    end;
  end;


  }



  {procedure TForm1.sandstatus(Sender: TObject);
var
  i : integer;
begin
  status := '';
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
  WSocket1.SendStr(status);
  ListBox1.Items.Add( '[SND] ' + status);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;


  {
  for i := 1 to length(status_divisionAddress){or ?????? ????}{ do
  begin
    word_count := k + 1;
    if

    status := status + Format('%03d', [word_count]);
  end;


  for i := 1 to length(status_divisionAddress) do
  begin
    for j := 1 to 4 do
    begin
      if (i - 1) * 3 + j <= length(status_divisionAddress) then
        status := status + '/ ' + status_divisionAddress[(i - 1) * 3 + j]
      else
        status := status + '/  ';
    end;
  end;
  }






procedure TForm1.ACStoAGV_SANDClick(Sender: TObject);
var
  sBuf1, sBuf2, sBuf3, sBuf4, sBuf5, sBuf6, sBuf7, sBuf8, sBuf9, sBuf10 : string;
  sBuf: array[1..10] of string;
  q : integer;
  SandStatus1: string;
  print_text: string;
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

  for i := 1 to Length(SandStatus1) do
  begin
    if SandStatus1[i] = '/' then
    begin
      ListBox1.Items.Add(print_text);
      print_text := '';
      j := j + 1;
    end
    else
    begin
      print_text := print_text + SandStatus1[i];
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
  //Edit_Chat.Text := '';

  WSocket1.SendStr(SandStatus1);
  ListBox1.Items.Add( '[SND] '+SandStatus1);             
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
  //change123();
end;


procedure TForm1.change123(Sender: TObject);
begin
  ACS_Data_1.Text := '123'
end;

end.
