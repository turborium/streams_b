unit ClassicParseFloat;

interface

procedure Test();
function ParseFloat(const Text: UnicodeString): Double;

implementation

uses
  Math, SysUtils;

function IeeeCharsToDouble(Str: PAnsiChar; PtrEnd: PPAnsiChar): Double; cdecl;
  {$IFDEF CPUX64}
  external 'IeeeConvert64.dll' name 'IeeeCharsToDouble'
  {$ELSE}
  external 'IeeeConvert32.dll' name 'IeeeCharsToDouble'
  {$ENDIF};

// from ieee_convert32.dll/ieee_convert64.dll
function IeeeStringToDouble(Str: UnicodeString): Double;
var
  AnsiStr: AnsiString;
begin
  AnsiStr := AnsiString(Str);// unicode -> ansi

  Result := IeeeCharsToDouble(PAnsiChar(AnsiStr), nil);// convert
end;

type
  TDigitsArray = array [0 .. 16] of Byte;

  TFixedDecimal = record
    Count: Integer;
    Exponent: Integer;
    IsNegative: Boolean;
    Digits: TDigitsArray;
  end;

function ReadTextToFixedDecimal(out Decimal: TFixedDecimal; const Text: PWideChar): Boolean;
const
  ClipExponent = 1000000;
var
  P: PWideChar;
  HasPoint, HasDigit: Boolean;
  ExponentSign: Integer;
  Exponent: Integer;
begin
  // clean
  Decimal.Count := 0;
  Decimal.IsNegative := False;
  Decimal.Exponent := -1;

  // read from start
  P := Text;

  // read sign
  case P^ of
  '+':
    begin
      Inc(P);
    end;
  '-':
    begin
      Decimal.IsNegative := True;
      Inc(P);
    end;
  end;

  // read mantissa
  HasDigit := False;// has read any digit (0..9)
  HasPoint := False;// has read decimal point
  while True do
  begin
    case P^ of
    '0'..'9':
      begin
        if (Decimal.Count <> 0) or (P^ <> '0') then
        begin
          // save digit
          if Decimal.Count < Length(Decimal.Digits) then
          begin
            Decimal.Digits[Decimal.Count] := Ord(P^) - Ord('0');
            Inc(Decimal.Count);
          end;
          // inc exponenta
          if (not HasPoint) and (Decimal.Exponent < ClipExponent) then
          begin
            Inc(Decimal.Exponent);
          end;
        end else
        begin
          // skip zero (dec exponenta)
          if HasPoint and (Decimal.Exponent > -ClipExponent) then
          begin
            Dec(Decimal.Exponent);
          end;
        end;
        HasDigit := True;
      end;
    '.':
      begin
        if HasPoint then
        begin
          exit(True);// make
        end;
        HasPoint := True;
      end;
    else
      break;
    end;
    Inc(P);
  end;

  if not HasDigit then
  begin
    exit(False);// fail
  end;

  // read exponenta
  if (P^ = 'e') or (P^ = 'E') then
  begin
    Inc(P);

    Exponent := 0;
    ExponentSign := 1;

    // check sign
    case P^ of
    '+':
      begin
        Inc(P);
      end;
    '-':
      begin
        ExponentSign := -1;
        Inc(P);
      end;
    end;

    // read
    if (P^ >= '0') and (P^ <= '9') then
    begin
      while (P^ >= '0') and (P^ <= '9') do
      begin
        Exponent := Exponent * 10 + (Ord(P^) - Ord('0'));
        if Exponent > ClipExponent then
        begin
          Exponent := ClipExponent;
        end;
        Inc(P);
      end;
    end else
    begin
      exit(True);// Make
    end;

    // fix
    Decimal.Exponent := Decimal.Exponent + ExponentSign * Exponent;
  end;

  exit(True);// Make
end;

function FixedDecimalToDouble(var Decimal: TFixedDecimal): Double;
var
  I: Integer;
  Exponent: Integer;
begin
  Result := 0.0;

  // set mantissa
  for I := 0 to Decimal.Count - 1 do
  begin
      Result := Result * 10;// * 10
      Result := Result + Decimal.Digits[I];// + Digit
  end;

  // set exponent
  Exponent := Decimal.Exponent - Decimal.Count + 1;

  //Result := Power10(Result, Exponent);
  Result := Result * Power(10.0, Exponent);

  // fix sign
  if Decimal.IsNegative then
  begin
    Result := -Result;
  end;
end;

function ParseFloat(const Text: UnicodeString): Double;
var
  Decimal: TFixedDecimal;
begin
  // Try read number
  if ReadTextToFixedDecimal(Decimal, PWideChar(Text)) then
  begin
    // Convert Decimal to Double
    Result := FixedDecimalToDouble(Decimal);
    exit;
  end;

  // Fail
  Result := 0.0 / 0.0;
end;

// ---

procedure Test();
var
  A: Double;
  BitA: UInt64 absolute A;
  B: Double;
  BitB: UInt64 absolute B;
  S: UnicodeString;
begin
  FormatSettings.DecimalSeparator := '.';

  S := '123.45';
  //S := '0.4796';
  //S := '0.4796e67';
  //S := '18014398509481993';
  //S := '18014398509481993e98';
  //S := '0.479442454433424242423423453534e-200';

  A := IeeeStringToDouble(S);
  B := ParseFloat(S);

  Writeln('S: "', S, '"');
  Writeln;
  Writeln('A: ', FloatToStr(A));
  Writeln('  A: ', FloatToStrF(A, ffExponent, 17, 17));
  Writeln('BitA: ', '0x', IntToHex(BitA, 8));
  Writeln;
  Writeln('B: ', FloatToStr(B));
  Writeln('  B: ', FloatToStrF(B, ffExponent, 17, 17));
  Writeln('BitB: ', '0x', IntToHex(BitB, 8));

  Readln;
end;
end.
