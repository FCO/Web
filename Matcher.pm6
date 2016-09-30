unit class Matcher;

has Str			$.source	is required;
has Regex		$!regex;
has Signature	$!signature;
has Bool		$.debug		= False;

my regex type {
	(\w+) <?{::($0) ~~ Mu:U}>
};

my regex var-name {
	\w+
};

my regex optional {
	'?'
};

my rule place-holder {
	'{' <type>? <var-name> <optional>? '}'
};

method BUILDALL(|) {
	callsame;
	self!build-regex;
	self
}

method !build-regex {
	use MONKEY-SEE-NO-EVAL;
	with $!source {
		my $regex = S:g/
			<place-holder>
		/"
			\$<{
				~$<place-holder><var-name>
			}>=\\w{
					$<place-holder><optional> ?? "*" !! "+"
			}
			<?\{
				!\$\<{~$<place-holder><var-name>}>.chars or
				{ ~($<place-holder><type> // "Str") }( \$\<{
					~$<place-holder><var-name>
			}> ) }>
		"/;
		$regex = '^ "' ~ $regex ~ '" $';
		say "REGEX: ", $regex.words.join(" ") if $!debug;
		$!regex = rx/<response=$regex>/;
	}
	no MONKEY-SEE-NO-EVAL;
}

method match(Str $path) {
	$path ~~ $!regex
}

method gist {$!source}
