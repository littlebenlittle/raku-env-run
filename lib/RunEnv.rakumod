
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

sub envs(*%new-envs) {
    state %envs;
    %envs = %new-envs if %new-envs;
    return %envs
}


our sub run-cmd (@cmd, *%env-tests) is export {
    # if '*' ∈ %env-tests {
    #     for %ENVS {
    #     }
    # }
    #%env-tests.say;
    #%env-tests.flat.say;
    for %env-tests.flat -> $a, $b {
        #$a.say;
        #$b.say;
    }
    return;
    for %env-tests -> $name, &test {
        my $proc = Proc::Async.new: @cmd, :out, :err;
        my $result = %();
        react {
            whenever $proc.stdout { $result<stdout> = $_; }
            whenever $proc.stderr { $result<stderr> = $_; }
            whenever $proc.start( ENV => %ENVS{$_} ) {
                say $result;
                %env-tests<*>($result);
                done
            }
        }
    }
}

