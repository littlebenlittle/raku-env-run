
unit module Test::CLI;

grammar kv {
    token TOP {
        <.ws>*
        <kv-pair>+ % <.ws>
        <.ws>*
    }
    token ws  { \v | \h }
    token kv-pair { <key> "=" <val> }
    token key { <.alpha> <.alnum>* }
    token val { <.alnum>+ }
}

class kv-actions {
    method TOP ($/) {
        make %($/<kv-pair>.map: *.made);
    }
    method kv-pair ($/) {
        make $/<key>.Str => $/<val>.Str;
    }
}
