#unit class Web::Server;
use HTTP::Easy::PSGI;
unit role Web::Server[::ServerType = HTTP::Easy::PSGI];
use Response;

has $!http = ServerType;

method listen(UInt $port) {
	$!http .= new: :$port;
	$!http.handle(self.^find_method("handle").assuming(self));
}

method handle(%env) {
	start {
		my $res = Web::Response.new;
		for %env -> (:$key, :$value) {
			#next unless $key.starts-with: "HTTP";
			$res.write: "$key => {$value.perl}\n"
		}
		my $name = %env<QUERY_STRING> || "World";
		#200, [ "Content-Type" => "text/plain" ], ["Hello",  $name]
		$res.P6W
	}
}
