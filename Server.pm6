#unit class Web::Server;
use HTTP::Easy::PSGI;
unit role Web::Server[::ServerType = HTTP::Easy::PSGI];

has $!http = ServerType;

method listen(UInt $port) {
	$!http .= new: :$port;
	$!http.handle($.handle);
}

method handle {
	sub (%env) {
		my $name = %env<QUERY_STRING> || "World";
		[ 200, [ "Content-Type" => "text/plain" ], [ "Hello $name" ] ];
	}
}
