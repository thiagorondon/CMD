var imposto = 1000;
var last_year = 2010;
function getNode(year,id) {
	var url = '/collection/' + year + '/node/' + id + '?imposto=' + imposto;
	geturljson(url,year);
}

function getYear(year) {
	var url = '/collection/' + year + '/root?imposto=' + imposto;
	geturljson(url,year);
}

function geturljson(url,year) {
	last_url = url;
	$.getJSON(url, function(rdata) {
		$('.my-new-list').empty();
  		var data = rdata.data;
		if (rdata.children != ""){
			showData(data,rdata,url,year);
			$('.total').html("Total: R$ " + rdata.total_tree);
		}else{
			document.location.href = "/year/" + rdata.current_model;
		}
	});

}

function showData(data,rdata,url,year) {
	OpenSpending.DatasetPage.init({
	        treemapData:  rdata
	});
	
	var items = [];

	items.push('<table id="datalist" class="tablesorter" width="95%" align="center"><thead><tr><th>Descri&ccedil;&atilde;o</th><th>Total de gastos</th><th>Quanto você gastou ?</th><th>Porcentagem nesta vis&atilde;o</th></tr></thead><tbody>');
	$.each(rdata.children, function(key, val) {
		items.push('<tr class="alt"><td width="320">' + '<a href="#">' + val.data.title + '</a></td><td align="right">R$ ' + val.data.valor_tabela + '</td><td align="right">R$ ' + val.data.valor_usuario + '</td><td align="right" width="200">' + val.data.porcentagem + '%</td></tr>');
	});
	items.push('</tbody></table>');

	items.push("<br />Formato aberto dos dados listados nesta página em JSON: ");
	items.push("<a href='" + url + "' target='_blank'>http://www.paraondefoimeudinheiro.com.br" + url + "</a><br />");
	
	$('.my-new-list').html(items.join(''));

	var myTextExtraction = function(node)  
	{  
	    // extract data from markup and return it  
		var conteudo = node.innerHTML;
		if (conteudo.search("href") < 0){
			conteudo = conteudo.replace(" ","");
			conteudo = conteudo.replace("R$","");
			conteudo = conteudo.replace("%","");
			conteudo = conteudo.replace(/\./gi,"");
			conteudo = conteudo.replace(/\,/gi,".");
			conteudo = parseFloat(conteudo);
		}else{
			conteudo = node.childNodes[0].innerHTML;
		}
		return conteudo;
	} 	
	$.tablesorter.defaults.sortList = [[1,1]]; 
	$.tablesorter.defaults.textExtraction = myTextExtraction; 
	$("#datalist").tablesorter();

}
$(document).ready(function() {
        $("#imposto").slider ( {
		value: 1000,
		min: 1000,
		max: 1000000,
		step: 1000,
		slide: function( event, ui ) {
			var formated_value = $().number_format(ui.value, {
			numberOfDecimals:2,
			decimalSeparator: ',',
			thousandSeparator: '.',
			symbol: 'R$'});
 			$( "#amount" ).val( formated_value );
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

