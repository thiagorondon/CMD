var OpenSpending = OpenSpending || {};

OpenSpending.DatasetPage = {
    View: {},
    Controller: {},
    init: function(config) {
        var e = new OpenSpending.DatasetPage.Controller(config);
        Backbone.history.start();
        return e;
    }
};

OpenSpending.DatasetPage.Controller = Backbone.Controller.extend({
        routes: {
            "": "treemap",
            "treemap": "treemap",
            "timeseries": "timeseries"
        },
        initialize: function(config) {
            this.config = config;
            this.view = new OpenSpending.DatasetPage.View();
            $("#_vis_select").change(function(e){
                window.location.hash = "#"+e.target.value;
                return false;
            });
        },
        treemap: function(){
            this.view.renderTreemap(this.config.treemapData);
        },
        timeseries: function(){
            this.view.renderTimeseries(this.config.timeseriesData);
        }
});

OpenSpending.DatasetPage.View = Backbone.View.extend({
    initialize: function() {
        this.config = {};
        var ua = navigator.userAgent,
          iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
          typeOfCanvas = typeof HTMLCanvasElement,
          nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
          textSupport = nativeCanvasSupport && 
              (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
        //I'm setting this based on the fact that ExCanvas provides text support for IE
        //and that as of today iPhone/iPad current text support is lame
        this.config.labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
        this.config.nativeTextSupport = this.config.labelType == 'Native';
        this.config.useGradients = nativeCanvasSupport;
        this.config.animate = !(iStuff || !nativeCanvasSupport);
    },
    renderTreemap: function(json) {
        $("#_vis_select").val("treemap");
        $("#_time_select").css("visibility", "visible");
        $("#mainvis").html("");
        this._renderTreemap(json, this.config);
    },
    renderTimeseries: function(json) {
        $("#_vis_select").val("timeseries");
        $("#_time_select").css("visibility", "hidden");
        $("#mainvis").html("");
        this._renderTimeseries(json, this.config);
    },
    _renderTreemap: function(json, config){
        var tm = new $jit.TM.Squarified({
            injectInto: 'mainvis',
            levelsToShow: 1,
            titleHeight: 0,
            animate: config.animate,

            offset: 2,
            Label: {
              type: 'HTML',
              size: 12,
              family: 'Tahoma, Verdana, Arial',
              color: '#DDE7F0'
              },
            Node: {
              color: '#243448',
              CanvasStyles: {
                shadowBlur: 0,
                shadowColor: '#000'
              }
            },
            Events: {
              enable: true,
              onClick: function(node) {
                if(node) {
                    document.location.href = node.data.link;
                }
              },
              onRightClick: function() {
                tm.out();
              },
              onMouseEnter: function(node, eventInfo) {
                if(node) {
                  node.setCanvasStyle('shadowBlur', 8);
                  node.orig_color = node.getData('color');
                  node.setData('color', '#A3B3C7');
                  tm.fx.plotNode(node, tm.canvas);
                  // tm.labels.plotLabel(tm.canvas, node);
                }
              },
              onMouseLeave: function(node) {
                if(node) {
                  node.removeData('color');
                  node.removeCanvasStyle('shadowBlur');
                  node.setData('color', node.orig_color);
                  tm.plot();
                }
              }
            },
            duration: 1000,
            Tips: {
              enable: true,
              type: 'Native',
              offsetX: 20,
              offsetY: 20,
              onShow: function(tip, node, isLeaf, domElement) {
                var html = '<div class="tip-title">' + node.name +
                    ': ' + node.data.printable_value +
                    '</div><div class="tip-text">';
                var data = node.data;
                tip.innerHTML =  html; 
              }  
            },
            //Implement this method for retrieving a requested  
            //subtree that has as root a node with id = nodeId,  
            //and level as depth. This method could also make a server-side  
            //call for the requested subtree. When completed, the onComplete   
            //callback method should be called.  
            request: function(nodeId, level, onComplete){  
              // var tree = eval('(' + json + ')');
              var tree = json;  
              var subtree = $jit.json.getSubtree(tree, nodeId);  
              $jit.json.prune(subtree, 1);  
              onComplete.onComplete(nodeId, subtree);  
            },
            //Add the name of the node in the corresponding label
            //This method is called once, on label creation and only for DOM labels.
            onCreateLabel: function(domElement, node){
                //console.log(node);
                if (node.data.show_title) {
                    domElement.innerHTML = "<div class='desc'><h2>" + node.data.printable_value + "</h2>" + node.name + "</div>";
                } else {
                    domElement.innerHTML = "&nbsp;";
                }
            }
        });
        tm.loadJSON(json);
        tm.refresh();
    },
    _renderTimeseries: function(json, config) {
        var ac = new $jit.AreaChart({ 
        injectInto: 'mainvis',
        levelsToShow: 1,
        titleHeight: 0,
        Margin: {
            top: 5,
            left: 5,
            right: 5,
            bottom: 5
        },
        labelOffset: 10,
        animate: config.animate,
        showLabels: true,
        Label: {
          type: 'HTML',
          size: 12,
          family: 'Tahoma, Verdana, Arial',
          color: '#000'
        },

        Node: {
          /*color: '#243448',*/
          CanvasStyles: {
            shadowBlur: 0,
            shadowColor: '#000'
          }
        },
        Events: {
            enable: true,
            onClick: function(node) {
                console.log(node);
                if(node) {
                    document.location.href = json.details[node.name].link;
                }
            },
            onRightClick: function() {
                ac.out();
            }
        },
        duration: 500,
        Tips: {
            enable: true,
              type: 'Native',
              offsetX: 20,
              offsetY: 20,
              onShow: function(tip, elem) {
                 tip.innerHTML = "<b>" +
                     json.details[elem.name].title +
                    "</b>: " +
                    OpenSpending.Utils.formatAmount(elem.value);
                  }
            }
        });
        ac.colors = json.colors;
        var temp = ac.st.config.onPlaceLabel;
        ac.st.config.onPlaceLabel = function(domElement, node){
            temp(domElement, node);
            var el = $($("div >div", domElement)[1]);
            if (el) {
                el.text(OpenSpending.Utils.formatAmount(el.text()));
            }
        };
        ac.loadJSON(json);
    }
});
