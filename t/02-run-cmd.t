
use Test;
use Env::Run;
plan 4;

envs(
    env1 => "NAME=world",
    env2 => "NAME=littlebenlittle",
);

run-cmd(
    « $*EXECUTABLE -e 'say "hello " ~ %*ENV<NAME>' »,
    env1 => {
        ok .proc.exitcode == 0, "proc exits with code 0";
        ok .stdout eq "hello world\n", "env var injection works #1";
    },
    env2 => {
        ok .proc.exitcode == 0, "proc exits with code 0";
        ok .stdout eq "hello littlebenlittle\n", "env var injection works #2";
    },
);

done-testing();

