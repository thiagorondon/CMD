var imposto = 1000;
var last_year = 2010;

function getNode(year,id) {
	var url = '/collection/' + year + '/node/' + id + '?imposto=' + imposto;
	geturljson(url);
}

function getYear(year) {
	var url = '/collection/' + year + '/root?imposto=' + imposto;
	geturljson(url);
}

function geturljson(url) {
	$.getJSON(url, function(rdata) {
  		var data = rdata.data;
		$('.my-new-list').empty();
		showData(data,rdata);
	});

}

function showData(data,rdata) {
	OpenSpending.DatasetPage.init({
	        treemapData:  rdata
	});
	
	var items = [];

	items.push('<table class="tabela" width="95%" align="center"><tr><th>Area</th><th>Gastos</th><th>Quanto você gastou ?</th><th>Porcentagem</th></tr>');
	$.each(rdata.children, function(key, val) {
		items.push('<tr><td>' + '<a href="/node/' + [% year %] + '/' + val.id + '">' + val.data.title + '</a></td><td>' + val.data.valor_tabela + '</td><td>' + val.data.valor_usuario + '</td><td>' + val.data.porcentagem + '%</td></tr>');
	});
	items.push('</table>');

	$('.my-new-list').html(items.join(''));
	
}

$(document).ready(function() {
        $("#imposto").slider ( {
		value: 1000,
		min: 1000,
		max: 10000000,
		step: 1000,
		slide: function( event, ui ) {
			$( "#amount" ).val( "R$" + ui.value );
			imposto = ui.value;
		},
		change: function( event, ui ) {
			getYear(last_year);
		}
	});

});

function changeYear() {
	var url = '/year/' + $('#year').val();
	window.location.replace(url);
}

