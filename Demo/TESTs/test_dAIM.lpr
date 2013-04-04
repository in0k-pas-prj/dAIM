program test_dAIM;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  dAim_CountB,
  Forms, fpcunittestrunner, GuiTestRunner;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TGUITestRunner, TestRunner);
  Application.Run;
end.

