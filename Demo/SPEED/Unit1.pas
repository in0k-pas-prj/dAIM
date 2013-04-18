unit Unit1;

{$mode objfpc}{$H+}

interface

uses  {LCLIntf, LCLProc, }windows, dAim_CountB,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;


  tTestThread=class(TThread)
  protected
    lpCreationTime_01,
    lpExitTime_01,
    lpKernelTime_01,
    lpUserTime_01: TFileTime;
    lpCreationTime_02,
    lpExitTime_02,
    lpKernelTime_02,
    lpUserTime_02: TFileTime;
    d1,d2:dWord;
    procedure do_Start; //inline;
    procedure do_Stop;  //inline;
  protected
    procedure Execute; override;
  public
    constructor Create;
    procedure get_Results(out lpCreationTime: TFileTime; out lpExitTime: TFileTime; out lpKernelTime: TFileTime; out lpUserTime: TFileTime; out D:dWord);
  end;


  tTestThread1=class(tTestThread)
  protected
    procedure Execute; override;
   end;


var
  Form1: TForm1;

implementation

{$R *.lfm}

constructor tTestThread.Create;
begin
    inherited Create(TRUE);
    self.FreeOnTerminate:=FALSE;

    QWord(lpCreationTime_01):=0;
    QWord(lpExitTime_01):=0;
    QWord(lpKernelTime_01):=0;
    QWord(lpUserTime_01):=0;
    QWord(lpCreationTime_02):=0;
    QWord(lpExitTime_02):=0;
    QWord(lpKernelTime_02):=0;
    QWord(lpUserTime_02):=0;
    d1:=0;
    d2:=0;
end;

procedure tTestThread.do_Start; //inline;
var h:THandle;
begin
    h:=self.Handle;
    h:=GetCurrentThread;
    d1:=GetTickCount;
    GetThreadTimes(H,lpCreationTime_01,lpExitTime_01,lpKernelTime_01,lpUserTime_01);
end;

procedure tTestThread.do_Stop;  //inline;
var h:THandle;
begin
    h:=self.Handle;
    h:=GetCurrentThread;
    GetThreadTimes(H,lpCreationTime_02,lpExitTime_02,lpKernelTime_02,lpUserTime_02);
    d2:=GetTickCount;
end;

procedure tTestThread.get_Results(out lpCreationTime: TFileTime; out lpExitTime: TFileTime; out lpKernelTime: TFileTime; out lpUserTime: TFileTime; out D:dWord);
begin
    QWord(lpCreationTime):=QWord(lpCreationTime_02)-QWord(lpCreationTime_01);
    QWord(lpExitTime    ):=QWord(lpExitTime_02)-QWord(lpExitTime_01);
    QWord(lpKernelTime  ):=QWord(lpKernelTime_02)-QWord(lpKernelTime_01);
    QWord(lpUserTime    ):=QWord(lpUserTime_02)-QWord(lpUserTime_01);
    D:=d2-d1;
end;

procedure tTestThread.Execute;
var i,j:integer;
    asd:array of byte;
begin
    do_Start;
    //---
    for j:=1 to 10000 do begin
      for i:=1 to 254 do begin
         SetLength(asd,i);
         asd[i-1]:=byte(i);
         SetLength(asd,0);
      end;
    end;
    //---
    do_Stop;
end;

procedure tTestThread1.Execute;
var i,j:integer;
    asd:pointer;
    b:byte;
begin
    b:=222;
    do_Start;
    //---
    for j:=1 to 10000 do begin
      for i:=1 to 254 do begin
         dAimB_INITialize(asd,i{,b});
         dAimB_set_Value(asd,i-1,i);
         dAimB_FINALize(asd);
      end;
    end;
    //---
    do_Stop;
end;


{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var lpCreationTime_01,
    lpExitTime_01,
    lpKernelTime_01,
    lpUserTime_01: TFileTime;
var lpCreationTime_02,
    lpExitTime_02,
    lpKernelTime_02,
    lpUserTime_02: TFileTime;
   i:integer;
   a:integer;
   b:integer;
   d:dword;

   th:THandle;
       asd:array of byte;
   thr:tTestThread;
   th1:tTestThread1;
begin
   memo1.Clear;

 {  th:=GetCurrentThread;
   GetThreadTimes(th,lpCreationTime_01,lpExitTime_01,lpKernelTime_01,lpUserTime_01);
   //---

   for i:=1 to 10000 do begin
        SetLength(asd,i);
        asd[0]:=byte(i);
        SetLength(asd,0);
   end;

   {
   for i:=0 to 56000000 do begin
      if i>10 then begin
        a:=round(1/i);
        b:=trunc(2/1+i+a+(1/i));
      end;
   end;}
   //---
   GetThreadTimes(th,lpCreationTime_02,lpExitTime_02,lpKernelTime_02,lpUserTime_02);
   //---
   memo1.Lines.Add(IntToStr(int64(lpUserTime_02)-int64(lpUserTime_01)));
   memo1.Lines.Add(IntToStr(int64(lpKernelTime_02)-int64(lpKernelTime_01)));
   //---
   }


  // SetLength(asd,10000);
  // SetLength(asd,0);


   Application.ProcessMessages;
   thr:=tTestThread.Create;
   //with th1 do begin
      thr.Resume;
      thr.WaitFor;
      thr.get_Results(lpCreationTime_01,lpExitTime_01,lpKernelTime_01,lpUserTime_01,d);
      thr.Free;
   //end;
   //---
   memo1.Lines.add('===');
   memo1.Lines.Add(IntToStr(d));
   memo1.Lines.Add('lpCreationTime = '+IntToStr(QWord(lpCreationTime_01)));
   memo1.Lines.Add('lpExitTime = '+IntToStr(QWord(lpExitTime_01)));
   memo1.Lines.Add('lpKernelTime = '+IntToStr(QWord(lpKernelTime_01)));
   memo1.Lines.Add('lpUserTime = '+IntToStr(QWord(lpUserTime_01)));

   {Application.ProcessMessages;
   thr:=tTestThread1.Create;
   //with th1 do begin
      thr.Resume;
      thr.WaitFor;
      thr.get_Results(lpCreationTime_02,lpExitTime_02,lpKernelTime_02,lpUserTime_02,d);
      thr.Free;
   //end;
   //---
   memo1.Lines.add('===');
   memo1.Lines.Add(IntToStr(d));
   memo1.Lines.Add('lpCreationTime = '+IntToStr(QWord(lpCreationTime_02)));
   memo1.Lines.Add('lpExitTime = '+IntToStr(QWord(lpExitTime_02)));
   memo1.Lines.Add('lpKernelTime = '+IntToStr(QWord(lpKernelTime_02)));
   memo1.Lines.Add('lpUserTime = '+IntToStr(QWord(lpUserTime_02)));}
end;

procedure TForm1.Button2Click(Sender: TObject);
var lpCreationTime_01,
    lpExitTime_01,
    lpKernelTime_01,
    lpUserTime_01: TFileTime;
var lpCreationTime_02,
    lpExitTime_02,
    lpKernelTime_02,
    lpUserTime_02: TFileTime;
   i:integer;
   a:integer;
   b:integer;
   d:dword;

   th:THandle;
       asd:array of byte;
   thr:tTestThread;
   th1:tTestThread1;
begin
   Application.ProcessMessages;
   thr:=tTestThread1.Create;
   //with th1 do begin
      thr.Resume;
      thr.WaitFor;
      thr.get_Results(lpCreationTime_02,lpExitTime_02,lpKernelTime_02,lpUserTime_02,d);
      thr.Free;
   //end;
   //---
   memo1.Lines.add('===');
   memo1.Lines.Add(IntToStr(d));
   memo1.Lines.Add('lpCreationTime = '+IntToStr(QWord(lpCreationTime_02)));
   memo1.Lines.Add('lpExitTime = '+IntToStr(QWord(lpExitTime_02)));
   memo1.Lines.Add('lpKernelTime = '+IntToStr(QWord(lpKernelTime_02)));
   memo1.Lines.Add('lpUserTime = '+IntToStr(QWord(lpUserTime_02)));
end;

end.

