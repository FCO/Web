unit class Web::Route::Matcher;
enum HTTPVerbs is export <GET POST PUT DELETE HEAD PATCH>;

has Str			$.path	is required;
has Regex		$!regex;
has Signature	$!signature;
has Bool		$.debug		= False;
has HTTPVerbs	$.verb		= GET;

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
	with $!path {
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

method match-verb(HTTPVerbs \verb) {
	verb == $!verb
}

method match-path(Str $path) {
	$path ~~ $!regex
}

method gist {
	"{$!verb.uc} {$!path}"
}






