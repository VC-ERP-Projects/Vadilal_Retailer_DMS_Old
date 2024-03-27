<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="OrderMap.aspx.cs" Inherits="Reports_OrderMap" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <%--<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAniPXwmmJ66mOdfGNY5SaVxBkRbfj6KPA&libraries=visualization"></script>GIVEN BY ANAND FROM KRUNAL LP GOOGLE ACCOUNT AFTER MAP CLOSE--%>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA1ulv4v-Q4ERLzGn-e6cF2gbpIlOG1ZU4&libraries=visualization"></script>
    <script type="text/javascript">

        var coordinates = new Array();
        var bounds;
        var map;
        var totaldistance = 0;
        var totalDistanceTra = 0;

        function GMAP(Data) {

            coordinates = new Array();
            totaldistance = 0;
            totalDistanceTra = 0;

            bounds = new google.maps.LatLngBounds();
            var mapDiv = document.getElementById('dvMap');

            map = new google.maps.Map(mapDiv, {
                center: new google.maps.LatLng(12.9715987, 77.5945627),
                zoom: 4,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                suppressMarkers: true
            });

            var markers = $.parseJSON(Data);

            for (i = 0; i < markers.length; i++) {

                var data = markers[i];

                var point = new google.maps.LatLng(parseFloat(data.lat), parseFloat(data.lng));

                coordinates.push(point);

                addMarker(data.lat, data.lng, data.id, data.color, data.desc);
            }

            calculateRoute(coordinates, true);
        }

        function addMarker(lat, lng, id, color, desc) {

            var markerSale = new google.maps.Marker({
                position: new google.maps.LatLng(lat, lng),
                map: map,
                icon: '//chart.googleapis.com/chart?chst=d_map_pin_letter&chld=' + id + '|' + color,
            });

            bounds.extend(new google.maps.LatLng(lat, lng));
            map.fitBounds(bounds);

            var infowindow = new google.maps.InfoWindow(
            {
                content: '<div id="infocontainer" style="height:80px;width:250px;font-size:11px;">' + '<p><b>' + desc + '</b></p>' + '</div>' + '<div class="iw-bottom-gradient"></div>' + '</div>',
            });

            google.maps.event.addListener(markerSale, 'mouseover', function () {
                infowindow.open(map, markerSale);
            });
            google.maps.event.addListener(markerSale, 'mouseout', function () {
                infowindow.close(map, markerSale);
            });


        }

        function calculateRoute(coordinates, displayDistance) {

            var startpoint = coordinates.shift();
            var endpoint = '';
            var waypts = [];
            var len = coordinates.length;
            for (var i = 0; i < len; i++) {
                var point = coordinates.shift();
                if (point == undefined)
                    continue;
                waypts.push({ location: point, stopover: true });
                if (waypts.length == 8) {
                    if (coordinates.length > 0)
                        endpoint = coordinates.shift();
                    else
                        endpoint = waypts.pop().location;
                    drawroute(startpoint, endpoint, waypts, displayDistance);
                    startpoint = endpoint;
                    waypts = [];
                }
            }
            if (waypts.length > 0) {
                endpoint = waypts.pop().location;
                drawroute(startpoint, endpoint, waypts, displayDistance);
            }
        }


        function drawroute(startpoint, endpoint, waypts, displayDistance) {

            if (typeof startpoint == 'undefined' || typeof endpoint == 'undefined')
                return;
            var directionsService = new google.maps.DirectionsService();
            var directionsRequest = {
                origin: startpoint,
                destination: endpoint,
                waypoints: waypts,
                optimizeWaypoints: false,
                travelMode: google.maps.DirectionsTravelMode.DRIVING,
                unitSystem: google.maps.UnitSystem.METRIC
            };
            directionsService.route(
              directionsRequest,
              function (response, status) {
                  if (status == google.maps.DirectionsStatus.OK) {

                      new google.maps.DirectionsRenderer({
                          map: map,
                          directions: response,
                          suppressMarkers: true,
                          preserveViewport: true
                      });

                      if (displayDistance) {
                          for (i = 0; i < response.routes[0].legs.length; i++) {
                              totaldistance += (response.routes[0].legs[i].distance.value) / 1000;
                          }
                          if (totaldistance > totalDistanceTra) {
                              $("#body_lblTotDis").empty();
                              $("#body_lblTotDis").text(totaldistance.toFixed(2));
                          }
                      }

                      map.fitBounds(bounds);
                  }
                  else {
                  }
              });

        }

    </script>

    <style>
        .lblTotDis {
            font: bold;
            color: darkblue;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="For Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" TabIndex="5" CssClass="btn btnGenerat btn-default" OnClick="btnGenerat_Click" />
                        &nbsp;
                        <asp:Button ID="btnPrintPDF" runat="server" Text="Convert to PDF" TabIndex="6" CssClass="btn btn-default" OnClick="btnPrintPDF_Click" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" id="divEmpCode" runat="server">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" TabIndex="6" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <asp:Literal Text="" ID="ltrBrand" runat="server" />
                </div>
                <div class="col-lg-5">
                    <div class="input-group form-group">
                        <table class="table table-bordered table-responsive" style="font-weight: bold; font-size: 9px">
                            <tr>
                                <td style="background-color: #19ff21;">Day Start</td>
                                <td style="background-color: #f9aa7b;">PR Call - 
                                        <asp:Label ID="lblTotPrd" runat="server" Text="0"></asp:Label></td>
                                <td style="background-color: #f442df;">NPR Call - 
                                        <asp:Label ID="lblTotNonPrd" runat="server" Text="0"></asp:Label></td>
                                <td style="background-color: #ffc518;">Loc Trac. - 
                                        <asp:Label ID="lblLocTrack" runat="server" Text="0"></asp:Label></td>
                                <td style="background-color: #ef1c09;">Day End</td>
                            </tr>
                            <tr>
                                <td>Total Calls - 
                                        <asp:Label ID="lblTotCall" runat="server" Text="0"></asp:Label></td>
                                <td>Call Duration - 
                                        <asp:Label ID="lblCallDur" runat="server" Text="0"></asp:Label></td>
                                <td>Trans. Time - 
                                        <asp:Label ID="lblTransTime" runat="server" Text="0"></asp:Label></td>
                                <td>Work Hours - 
                                        <asp:Label ID="lblWorkHr" runat="server" Text="0"></asp:Label></td>
                                <td>Total KM -
                                        <asp:Label ID="lblTotDis" runat="server" Text="0" Style="display: none;"></asp:Label>
                                    <asp:Label ID="lblSFATotDis" runat="server" Text="0" Style="display: none;"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div id="dvMap" style="width: 100%; height: 425px;"></div>
                    <div id="control_panel" style="float: right; width: 30%; text-align: left; padding-top: 20px">
                        <div id="directions_panel" style="margin: 20px; background-color: #FFEE77;"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

