/////////////////////////////////////////////////////////////////
/////////////          ////         //////    //////  ///////////
////////////  /////////////  /////  //////  /  /////  ///////////
///////////  //////////////  /////  //////  //  ////  ///////////
//////////          ///////  /////  //////  ///  ///  ///////////
/////////////////  ////////  /////  //////  ////  //  ///////////
////////////////  /////////  /////  //////  /////  /  ///////////
///////          //////////         //////  //////    ///////////
/////////////////////////////////////////////////////////////////
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OverbyteIcsWndControl, OverbyteIcsWSocket, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    WSocket1: TWSocket;
    ListBox1: TListBox;
    Edit_Chat: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
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
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WSocket1SessionConnected(Sender: TObject; ErrCode: Word);
    procedure WSocket1SessionClosed(Sender: TObject; ErrCode: Word);
    procedure WSocket1DataAvailable(Sender: TObject; ErrCode: Word);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    //function GetNextToken(Const S:string ; Separator:char ; var StartPos:integer): String;
    //procedure Edit1Change(Sender: TObject);
    //procedure SandStatus(Sender: TObject);
    //procedure ACStoAGV_SANDClick(Sender: TObject);
    //procedure change123(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Buffer: array[0..1023] of AnsiChar; // Socket Receive占쏙옙 활占쏙옙
  status: array[0..1023] of AnsiChar;
  i, j, k, word_count: Integer;
  AGV_Number: array[0..3] of AnsiChar;
  AGV_X: array[0..3] of AnsiChar;
  AGV_Y: array[0..3] of AnsiChar;
  AGV_Rotate: array[0..3] of AnsiChar;
  AGV_Speed: array[0..3] of AnsiChar;
  status_divisionAddress: array[0..3] of AnsiChar;
  RcvdLine: string;
  cmd_count: string;
  receive_command: array[0..10] of string;

implementation

{$R *.dfm}
{
//function
//procedure
function TForm1.GetNextToken(const S: string; Separator: char; var StartPos: integer): String;
var
  Index: integer;
  Result:  Longint;
begin
  Result := '';
  //
  if   (S[StartPos] = Separator) and (StartPos <= length(S)) then
  begin
    StartPos := StartPos + 1;
    Result := '' ;
    Index := StartPos;
  end
  else
  begin
    if   (StartPos > length(S)) then
    begin
      Exit;
    end ;
    //
    Index := StartPos;
    //
    while (S[Index] <> Separator) and (Index <= length(S))do
    begin
      Index := Index + 1;
    end ;
    //
    Result := Copy(S, StartPos, Index - StartPos) ;
    StartPos := Index + 1;
  end;
end;
}

procedure TForm1.Button1Click(Sender: TObject);
var
  sLog: string;
begin

  if (WSocket1.State <> wsConnected) then // 占쏙옙占쏙옙占쏙옙占?占십았다몌옙
  begin
    { Not connected yet, start connection }
    try
      try
        with WSocket1 do
        begin
          Proto := 'tcp';
          Port := '1001';
          Addr := '127.0.0.21';
          LineMode := TRUE;
          LineEnd := #13#10;
          //Name     := 'AGV01'; // ex) IndyClient[0], IndyClient[1] ...
          Tag := 0;
        end;
        WSocket1.Connect;
      except
        //
        WSocket1.Close;
      end;
    finally
      if WSocket1.State = wsClosed then
      begin
        WSocket1.Connect;
      end;
    end;

    { Connect is asynchronous (non-blocking). When the session is  }
    { connected (or fails to), we have an OnSessionConnected event }
    { This is where actual sending of data is done.                }
    ListBox1.Items.Add('Waiting to host...');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;

  end
  else
  begin
    Application.messagebox(PChar('이미 연결됨.'), 'WARNING', MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  sLog: string;
begin
  if (WSocket1.State <> wsConnected) then
  begin
    Application.messagebox(PChar('연결이미 끊어짐.'), 'WARNING', MB_OK or MB_ICONINFORMATION);
    Exit;
  end
  else
  begin
    try
      WSocket1.Close;
      //
      //INIT_AGV_Infomation(_nAGVNum);
    except
      //
    end;

    ListBox1.Items.Add('disconnected to host...');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end;
end;

procedure TForm1.WSocket1SessionConnected(Sender: TObject; ErrCode: Word);
var
  i: integer;
  sLog: string;
begin
  if ErrCode <> 0 then
  begin
    ListBox1.Items.Add('@ Can''t connect, error #' + IntToStr(ErrCode));
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end
  else
  begin
    ListBox1.Items.Add('AGVConnected');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end;
end;

procedure TForm1.WSocket1SessionClosed(Sender: TObject; ErrCode: Word);
begin
  if ErrCode <> 0 then
  begin
    ListBox1.Items.Add('Disconnected, error #' + IntToStr(ErrCode));
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end
  else
  begin
    ListBox1.Items.Add('Disconnected');
    ListBox1.ItemIndex := ListBox1.Items.Count - 1;
  end;
  //AGV1_Connect_Request := true;
end;

procedure TForm1.WSocket1DataAvailable(Sender: TObject; ErrCode: Word);
var
  nCount, Len, i, gnt: Integer;
  sTemp: string;
  print_text: string;
  Final_cmd_print: array[1..23] of string;
  slash_address: array[1..23] of Integer;
  Final_cmd_print_all: string;
  cmd_count_print: string;
  receive_command: string;
  nStartpos: integer;
  beforeslash, nowslash, nextslash : array[1..23] of Integer;
  beforeslash_address: integer;
  //cmd_string: string;
  //final_cmd_print2: TArray<string>;
begin

  { We use line mode, we will receive a complete line }
  Len := WSocket1.Receive(@Buffer, SizeOf(Buffer) - 1);

  Buffer[Len] := #0; { Nul terminate  }
  for i := 0 to 4096 do
  begin
    if (Buffer[i] = #13) or (Buffer[i] = #10) then
    begin
      Break;
    end
    else
    begin
      sTemp := sTemp + Buffer[i];
    end;
  end;
  ListBox1.Items.Add('[RCV] ' + sTemp);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;

  RcvdLine := sTemp;
  beforeslash_address := 0;
  print_text := '';
  j := 1;
  for i := 1 to Length(sTemp) do
  begin
    if RcvdLine[i] = '/' then
    begin
        beforeslash[j] := i;
      Final_cmd_print[j] := Copy(RcvdLine, beforeslash_address+1, i-beforeslash_address-1);
     j := j + 1;
      //ListBox1.Items.Add(IntToStr(j));
      beforeslash_address := i;
    end;
  end;
  Final_cmd_print[22] := Copy(RcvdLine, beforeslash_address+1, i-beforeslash_address);

  Edit1.Text := Final_cmd_print[2];
  Edit2.Text := Final_cmd_print[3];
  Edit3.Text := Final_cmd_print[4];
  Edit4.Text := Final_cmd_print[5];
  Edit5.Text := Final_cmd_print[6];
  Edit6.Text := Final_cmd_print[7];
  Edit7.Text := Final_cmd_print[8];
  Edit8.Text := Final_cmd_print[9];
  Edit9.Text := Final_cmd_print[10];
  Edit10.Text := Final_cmd_print[11];
  ACS_Data_11.Text := Final_cmd_print[12];
  ACS_Data_12.Text := Final_cmd_print[13];
  ACS_Data_13.Text := Final_cmd_print[14];
  ACS_Data_14.Text := Final_cmd_print[15];
  ACS_Data_15.Text := Final_cmd_print[16];
  ACS_Data_16.Text := Final_cmd_print[17];
  ACS_Data_17.Text := Final_cmd_print[18];
  ACS_Data_18.Text := Final_cmd_print[19];
  ACS_Data_19.Text := Final_cmd_print[20];
  ACS_Data_20.Text := Final_cmd_print[21];
  ACS_Data_21.Text := Final_cmd_print[22];

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  command, sBuf: string;
begin
  // WRITE
  sBuf := Edit_Chat.Text + Chr(13) + Chr(10);
  WSocket1.SendStr(sBuf);
  ListBox1.Items.Add('[SND] ' + sBuf);
  ListBox1.ItemIndex := ListBox1.Items.Count - 1;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ListBox1.Clear;
  Edit_Chat.Text := '';
  Edit1.Text := '';
  Edit2.Text := '';
  Edit3.Text := '';
  Edit4.Text := '';
  Edit5.Text := '';
  Edit6.Text := '';
  Edit7.Text := '';
  Edit8.Text := '';
  Edit9.Text := '';
  Edit10.Text := '';
  ACS_Data_11.Text := '';
  ACS_Data_12.Text := '';
  ACS_Data_13.Text := '';
  ACS_Data_14.Text := '';
  ACS_Data_15.Text := '';
  ACS_Data_16.Text := '';
  ACS_Data_17.Text := '';
  ACS_Data_18.Text := '';
  ACS_Data_19.Text := '';
  ACS_Data_20.Text := '';
  ACS_Data_21.Text := '';
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
  for i := 1 to length(status_divisionAddress){or data 占쏙옙占쏙옙}{ do
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

end.
