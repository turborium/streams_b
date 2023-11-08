program DoubleDoubleHello;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Hello in 'Hello.pas';

begin
  try
    Test();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
