program TestClassicParseFloat;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ClassicParseFloat in 'ClassicParseFloat.pas',
  Math;

begin
  try
    Test();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
