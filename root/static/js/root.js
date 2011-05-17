
$(document).ready(function() {
	$('#periodo').hide();	
});

function redirect2node() {
	if ($('#node').val()) {
		var url = '/node/' + $('#node').val();
		window.location.replace(url);
	}
}

function populate_periodo(url) {
	$.getJSON(url, function(ret) {
		data = ret.data;
		var options = '<option value=""></option>';
		for (var i = 0; i < data.length; i++) {
			options += '<option value="' + data[i].value + '">' + data[i].display + '</option>';
		}
		$("select#node").html(options);
	});
}

function base2nodes() {
        if ($('#base').val()) {
		var url = '/data/base2nodes/' + $('#base').val();
		$('#periodo').hide();
		populate_periodo(url);
		$('#periodo').show();
	}
}

