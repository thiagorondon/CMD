function redirect2node() {
	if ($('#node').val()) {
		var url = '/node/' + $('#node').val();
		window.location.replace(url);
	}
}

function populate_periodo(url, active_content) {
	$.getJSON(url, function(ret) {
		data = ret.data;
		var options = '<option value=""></option>';
		for (var i = 0; i < data.length; i++) {
			options += '<option value="' + data[i].value + '"';
			if (active_content == data[i].display) {
				options += " SELECTED"
			}
			options += '>' + data[i].display + '</option>';
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

