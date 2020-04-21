
use Test;
use Test::CLI;

my $kv = q:to/EOS/;
one=two
a=b
thr33=44
EOS

my %kvs = Test::CLI::kv.parse($kv, actions => Test::CLI::kv-actions).made;

ok %kvs<one>   eq "two", "first key";
ok %kvs<a>     eq "b"  , "second key";
ok %kvs<thr33> eq "44" , "third key";

done-testing();

