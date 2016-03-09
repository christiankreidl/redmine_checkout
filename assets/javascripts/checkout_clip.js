// only when Setting.checkout_use_zero_clipboard? 

$(document).ready(function(){
	if (typeof('ZeroClipboard') != 'undefined') {
    $('div#clipboard_container').show();
    clipboard = new ZeroClipboard.Client();
    clipboard.setHandCursor( true );
    clipboard.glue('clipboard_button', 'clipboard_container');

    clipboard.addEventListener('mouseOver', function (client) {
      clipboard.setText( $('#checkout_url').val() );
    });
  }
});
