
use Test;
use Test::CLI;

cli-timeout 0.123;
ok cli-timeout() == 0.123, "set and get cli timeout";

cli-envs(
    env1  => q:to/EOS/,
             MY_ENV_VAR=some-value
             EOS
    env2  => q:to/EOS/,
             MY_ENV_VAR=some value
             EOS
    other => q:to/EOS/,
             FOO=bau haus
             BAR="dig dog 123"
             _SYSTEM='a'
             EOS
);

is-deeply cli-envs(), %(
    env1 => %(
        MY_ENV_VAR => "some-value",
    ),
    env2 => %(
        MY_ENV_VAR => "some value",
    ),
    other => %(
         FOO     => "bau haus",
         BAR     => "dig dog 123",
         _SYSTEM => "a",
    ),
), "set and get envs";

cli-envs(env1 => 'GRPC_TARGET=localhost:50051');

is-deeply cli-envs()<env1>, %(GRPC_TARGET => "localhost:50051"),
    "set var to host:port";

done-testing();

