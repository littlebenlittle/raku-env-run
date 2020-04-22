
unit module Test::CLI;

our sub parse-kvs (Str:D $kvs) is export {
    my grammar kv {
        token TOP {
            <.ws>*
            <kv-pair>+ % <.ws>
            <.ws>*
        }
        token kv-pair { <key> "=" <val> }
        token key { <.alpha> [<.alnum> | "-"]* }
        token val {
            | <raw-val>
            | "'" <raw-val> "'" 
            | '"' <raw-val> '"' 
        }
        token raw-val { [<.alnum> | "-" | ":" | \h]+ }
        token ws  { \v | \h }
    }
    my class kv-actions {
        method TOP ($/) {
            make %($/<kv-pair>.map: *.made);
        }
        method kv-pair ($/) {
            make $/<key>.Str => $/<val><raw-val>.Str;
        }
    }
    kv.parse($kvs, :actions(kv-actions));
    my $env = $/.made;
    die "could not parse $kvs" unless $env;
    my %env = %($env);
    return %env;
}

my $timeout = 0.1;
our proto cli-timeout (|) {*}
our multi sub cli-timeout is export { $timeout = $^new-timeout; $timeout}
our multi sub cli-timeout is export { $timeout }

my %ENVS;
our sub cli-envs (*%envs) is export {
    for %envs {
        my $name = .key;
        my $kvs  = .value;
        my $env  = parse-kvs($kvs);
        %ENVS{$name} = %($env);
    }
    return %ENVS;
}

