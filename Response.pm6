unit class Web::Response;
use HTTP::Headers;

has UInt	$.state		= 404;
has			$.headers	= HTTP::Headers.new;
has			@.body handles write => "push";

method BUILDALL(|) {
	nextsame;
	$!headers.Content-Type = "application/json";
	$!headers.Content-Type.charset = "UTF-8";
	self
}

method P6W {
	$!state, $!headers.for-PSGI, @.body
}
