requires 'perl', '5.008001';
requires 'Params::Validate';
requires 'List::MoreUtils', '0.28';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
