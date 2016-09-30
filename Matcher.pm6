use nqp;
use QAST:from<NQP>;

class Web::Route::Matcher {

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
}

sub EXPORT(|) {
	role Web::Grammar {
		regex type {
			(\w+) <?{::($0) ~~ Mu:U}>
		}

		regex var-name {
			\w+
		}

		regex optional {
			'?'
		}

		rule place-holder {
			'{' <type>? <var-name> <optional>? '}'
		}
		rule statement_control:sym<GET> {
			<sym> '/' [\w+ | \w* <place-holder> \w*]+ % '/'
		}
	}
	role Web::Actions {
		method statement_control:sym<GET> {
			QAST::Op.new()
		}
	}
	nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, Web::Grammar));
	nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, Web::Actions));
	{}
}






