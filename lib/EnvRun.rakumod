
unit module Env::Run;

state %envs;

our sub envs (*%new-envs) is export {
    for (%new-envs.kv) -> $name, $kvs {
        %envs{$name} = parse-kvs($kvs)
    }
    return %envs
}

our sub parse-kvs (Str:D $kvs -->Hash:D) is export {
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

# TODO: ben.little 2020-04-22T11:57:46Z
#   Deprecate cli-envs in favor of Env::Run::envs
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

class Proc-Report {
    has Proc $.proc;
    has Str  $.stdout;
    has Str  $.stderr;
}

our sub run-cmd (@cmd, *%env-tests) is export {
    for %env-tests.kv -> $name, &callback {
        my %kvs = envs(){$name};
        my $out = '';
        my $err = '';
        react {
            with Proc::Async.new: @cmd, :out, :err {
                whenever .stdout { $out ~= $_ };
                whenever .stderr { $err ~= $_ };
                whenever .start(:ENV(%kvs))  { 
                    my $report = Proc-Report.new(
                        proc   => $_,
                        stdout => $out,
                        stderr => $err,
                    );
                    &callback($report);
                    done
                };
            }
        }
    }
}

