#`{{{
my $regex = rx{"/account/" $<acc_id> = [\d+]};
my $path = "/account/123";

if $path ~~ m{<a={$regex.clone}>} -> \match {
   say match<a>.Hash ~~ :(Int(Match) :$acc_id!)
}
}}}


unit class Matcher;

has Str			$.source	is required;
has Regex		$!regex;
has Signature	$!signature;

my regex type {
	(\w+) <?{::($0) ~~ Mu:U}>
};

my regex var-name {
	\w+
};

my rule place-holder {
	'{' <type>? <var-name> '}'
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
			}>=\\w+
			<?\{{ ~($<place-holder><type> // "Str") }( \$\<{
					~$<place-holder><var-name>
			}>) }>
		"/;
		$regex = '"' ~ $regex ~ '"';
		$!regex = rx/<response=$regex>/;
	}
	no MONKEY-SEE-NO-EVAL;
}

method match(Str $path) {
	$path ~~ $!regex
}

method gist {$!source}
