unit Hello;

interface

procedure Test();

implementation

uses
  Math, SysUtils;

type
  TDoubleDouble = record
    Hi, Lo: Double;
  end;

// Add two Double1 value, condition: |A| >= |B|
// The "Fast2Sum" algorithm (Dekker 1971) [1]
function DoubleDoubleFastAdd11(A, B: Double): TDoubleDouble; inline;
begin
  Result.Hi := A + B;

  Result.Lo := (B - (Result.Hi - A));
end;

// Addition Double2 and Double1
// The DWPlusFP algorithm [1]
function DoubleDoubleAdd21(const A: TDoubleDouble; B: Double): TDoubleDouble; inline;
begin
  if Abs(A.Hi) >= Abs(B) then
    Result := DoubleDoubleFastAdd11(A.Hi, B)
  else
    Result := DoubleDoubleFastAdd11(B, A.Hi);

  Result.Lo := Result.Lo + A.Lo;
  Result := DoubleDoubleFastAdd11(Result.Hi, Result.Lo);
end;

procedure Test();
var
  I: Integer;
  Num: Double;
  Num2: TDoubleDouble;
begin
  FormatSettings.DecimalSeparator := '.';

  Num := 0.0;
  for I := 0 to 99999 do
  begin
    Num := Num + 0.00001;
  end;
  Writeln('Num = ', FloatToStr(Num));

  Num2.Hi := 0.0;
  Num2.Lo := 0.0;
  for I := 0 to 99999 do
  begin
    Num2 := DoubleDoubleAdd21(Num2, 0.00001);
  end;
  Writeln('Num2.Hi = ', FloatToStr(Num2.Hi));
  Writeln('Num2.Lo = ', FloatToStr(Num2.Lo));

  Readln;
end;

end.
