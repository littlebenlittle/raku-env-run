
use Test;
use Test::CLI;

subtest "basic" => {
    try {
        my $kvs = parse-kvs(q:to/EOS/);
        one=two
        a=b
        thr33=44
        EOS
        my %kvs = %($kvs);
        ok %($kvs)<one>   eq "two", "first  kv parsed correctly";
        ok %($kvs)<a>     eq "b"  , "second kv parsed correctly";
        ok %($kvs)<thr33> eq "44" , "third  kv parsed correctly";
    }
    ok not $!, "parse ok";
}

subtest "all caps snake case key" => {
    try {
        my $kvs = parse-kvs(q:to/EOS/);
        MY_ENV_VAR=some-value
        EOS
        my %kvs = %($kvs);
        ok %($kvs)<MY_ENV_VAR> eq "some-value", "parsed correctly";
    }
    ok not $!, "parse ok";
}

subtest "quoted values" => {
    try {
        my $kvs = parse-kvs(q:to/EOS/);
        a='x'
        b="y"
        EOS
        ok %($kvs)<a> eq "x", "single-quoted value parsed correctly";
        ok %($kvs)<b> eq "y", "double-quoted value parsed correctly";
    }
    ok not $!, "parse ok";
}

done-testing();

