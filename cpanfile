requires 'perl', '5.008001';
requires 'Params::Validate';
requires 'List::MoreUtils';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal';
    requires 'Test::Warn';
};
