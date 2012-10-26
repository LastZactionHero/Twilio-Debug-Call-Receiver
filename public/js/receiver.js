var CURRENT_CONN;

$( document ).ready( function() {
	$( "#hangup" ).hide();
	$( "#accept" ).hide();
	
	$( "#hangup" ).click( function(){ hangup() } );
	$( "#accept" ).click( function(){ accept() } );
	$( '.digit' ).click( function(d){ digit( this ) } );
	
	/* Create the Client with a Capability Token */		
	Twilio.Device.setup(TOKEN, {debug: true});	
} );


/* Let us know when the client is ready. */
Twilio.Device.ready(function (device) {
	$("#log").text("Ready");
});

/* Report any errors on the screen */
Twilio.Device.error(function (error) {
	$("#log").text("Error: " + error.message);
});

Twilio.Device.connect(function (conn) {
	$("#log").text("Successfully established call");	
});

/* Log a message when a call disconnects. */
Twilio.Device.disconnect(function (conn) {
	$("#log").text("Call ended");
});								

 /* Listen for incoming connections */
Twilio.Device.incoming(function (conn) {	
	CURRENT_CONN = conn;	
	updateCallTable( conn );
	
	$("#log").text("Incoming connection from " + conn.parameters.From);
	$( "#hangup" ).show();
	$( "#accept" ).show();
});

			
 /* A function to end a connection to Twilio. */
function hangup() {	
	if( CURRENT_CONN ) {
		CURRENT_CONN.reject();
		CURRENT_CONN = null;
	}
	
	Twilio.Device.disconnectAll();
	
	$("#log").text("Hung up");
	$( "#hangup" ).hide();
	$( "#accept" ).hide();
}

function accept() {
	CURRENT_CONN.accept();
	$( "#accept" ).hide();
}

function updateCallTable(conn) {
	$( "#param-callsid" ).html( conn.parameters.CallSid );
	$( "#param-from" ).html( conn.parameters.From );
	$( "#param-to" ).html( conn.parameters.To );	
}

function digit( digit ) {
	if( CURRENT_CONN )
		CURRENT_CONN.sendDigits( $( digit ).html() );
}