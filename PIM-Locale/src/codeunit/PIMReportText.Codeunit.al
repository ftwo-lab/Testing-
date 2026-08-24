codeunit 50104 "PIM Report Text"
{
    procedure LimitTo250(Value: Text): Text[250]
    begin
        exit(CopyStr(Value, 1, 250));
    end;
}
