<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html><head>
    <%@ include file="head.jsp" %>
    <link href="<c:url value="/style/shadow.css"/>" rel="stylesheet">
    <script type="text/javascript" src="<c:url value="/script/jquery-1.7.1.min.js"/>"></script>

    <c:if test="${model.listType eq 'random'}">
        <meta http-equiv="refresh" content="20">
    </c:if>
	
    <c:if test="${model.listType eq 'hot'}">
		<link href="<c:url value="/style/carousel.css"/>" rel="stylesheet">
    </c:if>
	
    <c:if test="${model.listType eq 'hot'}">
    <script type="text/javascript" src="<c:url value="/script/jquery.mousewheel.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/script/jquery.event.drag-1.5.min.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/script/cloud-carousel.1.0.6.js"/>"></script>
	<script type="text/javascript">

	/* Call to the object carousel */
	$(document).ready(function(){
		$("#carousel1").CloudCarousel({			
		reflHeight: 56,
		reflGap:2,
		titleBox: $('#carousel1-title'),
		altBox: $('#carousel1-alt'),
		buttonLeft: $('#left-but'),
		buttonRight: $('#right-but'),
		yRadius: 50,
		xRadius: 340,
		xPos: 350,
		yPos: 30,
		speed: 0.10,
		minScale: 0.4,
		autoRotate: 'right',
		autoRotateDelay: 3000,
		bringToFront: true,
		mouseWheel: true,
		OpacityMode: true
		});
			
		/* Clicked on one of the banners - go to the page */
		$(".cloudcarousel").click(function(){
			link = $(this).attr("alt");
			setTimeout(goLink, 2500);
			function goLink() {
				if (typeof dragEnd == "undefined") dragEnd = true;
				if (dragEnd==true) document.location.href = link; 
			}	
		});
		
		/* Navigation carousel with dragging the mouse */
		var xpos = 0;
		var ypos = 0;
		var de;
		$('#carousel1')
			.bind('dragstart',function(event){
				xpos=event.offsetX;
				dragEnd=false;
				if (de!=false) clearTimeout(de);
			})
			.bind('drag',function(event){
					dragline=Math.abs(xpos-event.offsetX);
					mindrag=$(window).width()/14;
					if (Math.abs(xpos-event.offsetX)>mindrag) {
						n=Math.floor(dragline/mindrag);
						for (i=0;i<n;i++) {
							if (xpos<event.offsetX) $("#left-but").mouseup();
							if (xpos>event.offsetX) $("#right-but").mouseup();
						}
						xpos=event.offsetX;
					}
			})
			.bind('dragend',function(event){
				 de = setTimeout("dragEnd=true;", 1500);
			});
			
		/* Navigation using the arrow keys */
		$(document).keydown(function(e) {
			 if (e.keyCode == 39) { 
				$("#right-but").mouseup();
			 }   
			 if (e.keyCode == 37) { 
				$("#left-but").mouseup();
			 }   
 		})	
		
		/* Preloader */

		/* Change the properties of preloader */
		$("#preloader").css({
			"opacity":"0.9",
			"height":$("#resizable").height()
		});
		$("#preloaderText").css({
			"margin-top":$("#resizable").height()/2+20,
			"margin-left":$("#resizable").width()/2-60
		});
		$("#currentProcess").html("... Downloading ...");
		
		/* Percentage (for each image proportionally increases the number) */
		$("#carousel1 img").each(function() {
			$(this).load(function() {
				if (typeof imgCNumb == "undefined") imgCNumb = 0;
				$("#persent").html(Math.round(imgCNumb*100/17) + "%");
				imgCNumb++;
			});
		});
		
		/* The ability to stop the loading on a slow connection */
		$("#stopLoading").delay(4000).css("display","block");
		$("#stopLoading").click(function() {
			if (window.stop !== undefined) window.stop();
			else if (document.execCommand !== undefined) {
				document.execCommand("Stop",false);
			}
			Stopped = 1;
			$(this).hide("slow");
			$("#startLoading").show("slow");
			$("#currentProcess").html(" - ");
		});
		
		/* Resume download */
		$("#startLoading").click(function() {
			window.location.reload();
		});
		
		/* hide preloader when loading is complete */
		$(window).load(function() {
			if (typeof Stopped == "undefined") Stopped = 0;
			if (Stopped == 0) $("#preloader").delay(300).hide("fast"); 
		});
		
		/* Alignment adjustment - when the page is loaded and resized */
		$(window).bind('load resize', function() {
			
			$("#preloader").css("height",$("#resizable").height());	
			$("#preloaderText").css({
				"margin-top":$("#resizable").height()/2+40,
				"margin-left":$("#resizable").width()/2-60
			});	
		});
	});
	</script>
    </c:if>
	
</head>
<body class="mainframe bgcolor1">

<c:if test="${not empty model.welcomeTitle}">
	<h1>
		<img src="<spring:theme code="homeImage"/>" alt="">
		${model.welcomeTitle}
	</h1>
</c:if>

<c:if test="${not empty model.welcomeSubtitle}">
    <h2>${model.welcomeSubtitle}</h2>
</c:if>

<h2>
		<c:forTokens items="hot newest highest frequent recent random top new users" delims=" " var="cat" varStatus="loopStatus">
        <c:if test="${loopStatus.count > 1}">&nbsp;|&nbsp;</c:if>
        <sub:url var="url" value="home.view">
            <sub:param name="listType" value="${cat}"/>
            <sub:param name="listRows" value="${model.listRows}"/>
            <sub:param name="listColumns" value="${model.listColumns}"/>
        </sub:url>
        <c:choose>
            <c:when test="${model.listType eq cat}">
                <span class="headerSelected"><fmt:message key="home.${cat}.title"/></span>
            </c:when>
            <c:otherwise>
                <a href="${url}"><fmt:message key="home.${cat}.title"/></a>
            </c:otherwise>
        </c:choose>
    </c:forTokens>
</h2>
<c:if test="${model.isIndexBeingCreated}">
    <p class="warning"><fmt:message key="home.scan"/></p>
</c:if>
<h2><fmt:message key="home.${model.listType}.text"/><c:if test="${model.listType eq 'hot'}">: <p id="carousel1-title">Title</p></c:if></h2>

<table width="100%">
    <tr>
        <td style="vertical-align:top;">
<c:choose>
<c:when test="${model.listType eq 'hot'}">

	
	<img id="left-but" src="../icons/button/left.png" title=""  />
	<img id="right-but" src="../icons/button/right.png" title=""  />
	
	<div id="preloader">
		<div id="preloaderText">
			<span id="currentProcess"></span> 
			<span id="persent"></span>
			<div id="stopLoading">cancel</div>
			<div id="startLoading">resume Downloads</div>
		</div>
	</div>
	<div id="resizable">
		<div id = "carousel1" > 
		<c:forEach items="${model.albums}" var="album" varStatus="loopStatus">
			<c:import url="carousel.jsp">
				<c:param name="albumPath" value="${album.path}"/>
				<c:param name="albumName" value="${album.albumTitle}"/>
				<c:param name="albumArtist" value="${album.artist}"/>
				<c:param name="albumYear" value="${album.albumYear}"/>				
				<c:param name="coverArtSize" value="160"/>
				<c:param name="coverArtPath" value="${album.coverArtPath}"/>
				<c:param name="showLink" value="true"/>
			</c:import>				
		</c:forEach>
		</div>
	</div>
	<div id = "nextcontrols" > 
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<c:choose>
					<c:when test="${model.listType eq 'random'}">
					</c:when>
					<c:otherwise>
						<sub:url value="home.view" var="previousUrl">
							<sub:param name="listType" value="${model.listType}"/>
							<sub:param name="listRows" value="${model.listRows}"/>
							<sub:param name="listColumns" value="${model.listColumns}"/>
							<sub:param name="listOffset" value="${model.listOffset - model.listSize}"/>
						</sub:url>
						<sub:url value="home.view" var="nextUrl">
							<sub:param name="listType" value="${model.listType}"/>
							<sub:param name="listRows" value="${model.listRows}"/>
							<sub:param name="listColumns" value="${model.listColumns}"/>
							<sub:param name="listOffset" value="${model.listOffset + model.listSize}"/>
						</sub:url>
							<td width="33%"></td>
							<td width="80"><fmt:message key="home.albums"><fmt:param value="${model.listOffset + 1}"/><fmt:param value="${model.listOffset + model.listSize}"/></fmt:message></td>
							<td width="33%"></td>
						</c:otherwise>
					</c:choose>
				</tr>
		</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="33%"><div class="back"><a href="${previousUrl}"><fmt:message key="common.previous"/></a></div></td>
				<td width="100" style="padding-up:1.5em">
					<select name="listSize" onchange="location='home.view?listType=${model.listType}&amp;listOffset=${model.listOffset}&amp;listSize=' + options[selectedIndex].value;">
						<c:forTokens items="5 10 15 20 25 30 35" delims=" " var="size">
							<option ${size eq model.listSize ? "selected" : ""} value="${size}"><fmt:message key="home.listsize"><fmt:param value="${size}"/></fmt:message></option>
						</c:forTokens>
					</select>
				</td>
				<td width="33%"><div class="forward"><a href="${nextUrl}"><fmt:message key="common.next"/></a></div></td>
			</tr>
		</table>
	</div>

</c:when>
<c:when test="${model.listType eq 'users'}">
    <table>
        <tr>
            <th><fmt:message key="home.chart.total"/></th>
            <th><fmt:message key="home.chart.stream"/></th>
        </tr>
        <tr>
            <td><img src="<c:url value="/userChart.view"><c:param name="type" value="total"/></c:url>" alt=""></td>
            <td><img src="<c:url value="/userChart.view"><c:param name="type" value="stream"/></c:url>" alt=""></td>
        </tr>
        <tr>
            <th><fmt:message key="home.chart.download"/></th>
            <th><fmt:message key="home.chart.upload"/></th>
        </tr>
        <tr>
            <td><img src="<c:url value="/userChart.view"><c:param name="type" value="download"/></c:url>" alt=""></td>
            <td><img src="<c:url value="/userChart.view"><c:param name="type" value="upload"/></c:url>" alt=""></td>
        </tr>
</table>
</c:when>
<c:otherwise>
    <table>
        <c:forEach items="${model.albums}" var="album" varStatus="loopStatus">
            <c:if test='${loopStatus.count % model.listColumns == 1}'>
                <tr>
            </c:if>
            <td style="vertical-align:top">
                <table>
                    <tr><td>
                            <c:import url="coverArt.jsp">
                                <c:param name="albumPath" value="${album.path}"/>
                                <c:param name="albumName" value="${album.albumTitle}"/>
                                <c:param name="coverArtSize" value="110"/>
                                <c:param name="coverArtPath" value="${album.coverArtPath}"/>
                                <c:param name="showLink" value="true"/>
                                <c:param name="showZoom" value="false"/>
                                <c:param name="showChange" value="false"/>
                                <c:param name="appearAfter" value="${loopStatus.count * 30}"/>
                            </c:import>

                        <div class="detailmini">
                            <c:if test="${not empty album.playCount}">
							<div class="detailcolordark">
                                <fmt:message key="home.playcount"><fmt:param value="${album.playCount}"/></fmt:message>
							</div>
                            </c:if>
                            <c:if test="${not empty album.lastPlayed}">
								<div class="detailcolordark">
                                <fmt:formatDate value="${album.lastPlayed}" dateStyle="short" var="lastPlayedDate"/>
                                <fmt:message key="home.lastplayed"><fmt:param value="${lastPlayedDate}"/></fmt:message>
								</div>
                            </c:if>
                            <c:if test="${not empty album.created}">
								<div class="detailcolordark">
                                <fmt:formatDate value="${album.created}" dateStyle="short" var="creationDate"/>
                                <fmt:message key="home.created"><fmt:param value="${creationDate}"/></fmt:message>
								</div>
                            </c:if>
                            <c:if test="${not empty album.rating}">
                                <c:import url="rating.jsp">
                                    <c:param name="readonly" value="true"/>
                                    <c:param name="rating" value="${album.rating}"/>
                                </c:import>
                            </c:if>
                        </div>

                        <c:choose>
                            <c:when test="${empty album.artist and empty album.albumTitle}">
                                <div class="detail"><fmt:message key="common.unknown"/></div>
                            </c:when>
                            <c:otherwise>
                                <div class="detailcolor"><em><str:truncateNicely lower="15" upper="15">${album.artist}</str:truncateNicely></em></div>
                                <div class="detail"><str:truncateNicely lower="15" upper="15">${album.albumTitle}</str:truncateNicely></div>
                            </c:otherwise>
                        </c:choose>

                    </td></tr>
                </table>
            </td>
            <c:if test="${loopStatus.count % model.listColumns == 0}">
                </tr>
            </c:if>
        </c:forEach>
    </table>

<table>
    <tr>
		<td high=20>
		</td>
		<td>
		<select name="listRows" id="listRows" class="inputWithIcon vcenter" onchange="location='home.view?listType=${model.listType}&amp;listColumns=${model.listColumns}&amp;listRows=' + options[selectedIndex].value;">
			<c:forTokens items="1 2 3 4 5 6 7 8 9 10" delims=" " var="listrows">
				<option ${listrows eq model.listRows ? "selected" : ""} value="${listrows}"><fmt:message key="home.listrows"><fmt:param value="${listrows}"/></fmt:message>${listrows gt 1 ? pluralizer : ""}</option>
			</c:forTokens>
		</select>
				
		<select name="listColumns" id="listColumns" class="inputWithIcon vcenter" onChange="location='home.view?listType=${model.listType}&amp;listRows=${model.listRows}&amp;listColumns=' + options[selectedIndex].value;">
			<c:forEach begin="1" end="10" var="listcolumns">
				<c:if test="${listcolumns gt 10}">
					<c:set var="listcolumns" value="${((listcolumns - 10) * 5) + 10}"/>
				</c:if>
				<option ${listcolumns eq model.listColumns ? "selected" : ""} value="${listcolumns}"><fmt:message key="home.listcolumns"><fmt:param value="${listcolumns}"/></fmt:message>${listcolumns gt 1 ? pluralizer : ""}</option>
			</c:forEach>
		</select> 
		<Td>
		<c:choose>
		<c:when test="${model.listType eq 'random'}">
			<td><div class="forward"><a href="home.view?listType=random&amp;listRows=${model.listRows}&amp;listColumns=${model.listColumns}"><fmt:message key="common.more"/></a></div></td>
		</c:when>
		
		<c:otherwise>
			<sub:url value="home.view" var="previousUrl">
				<sub:param name="listType" value="${model.listType}"/>
				<sub:param name="listRows" value="${model.listRows}"/>
				<sub:param name="listColumns" value="${model.listColumns}"/>
				<sub:param name="listOffset" value="${model.listOffset - model.listSize}"/>
			</sub:url>
			<sub:url value="home.view" var="nextUrl">
				<sub:param name="listType" value="${model.listType}"/>
				<sub:param name="listRows" value="${model.listRows}"/>
				<sub:param name="listColumns" value="${model.listColumns}"/>
				<sub:param name="listOffset" value="${model.listOffset + model.listSize}"/>
			</sub:url>

			<td style="padding-right:1.5em"><div class="back"><a href="${previousUrl}"><fmt:message key="common.previous"/></a></div></td>
			<td style="padding-right:1.5em"><fmt:message key="home.albums"><fmt:param value="${model.listOffset + 1}"/><fmt:param value="${model.listOffset + model.listSize}"/></fmt:message></td>
			<td><div class="forward"><a href="${nextUrl}"><fmt:message key="common.next"/></a></div></td>
		</c:otherwise>
	</c:choose>

	    </tr>
    </table>
</c:otherwise>
</c:choose>
        </td>
            <c:if test="${not empty model.welcomeMessage}">
                <td style="vertical-align:top;width:20em">
                    <div style="padding:0 1em 0 1em;border-left:1px solid #<spring:theme code="detailColor"/>">
                        <sub:wiki text="${model.welcomeMessage}"/>
                    </div>
                </td>
            </c:if>
        </tr>
    </table>

    </body>
<script type="text/javascript">        
	function updateListOption(opt, val) {
		var newURI = 'home.view?listType='
		switch (opt) {
			case ("type"):    newURI += val + '&listRows=${model.listRows}&listColumns=${model.listColumns}&listOffset=${model.listOffset}'; break;
			case ("rows"):    newURI += '${model.listType}&listRows=' + val + '&listColumns=${model.listColumns}&listOffset=${model.listOffset}'; break;
			case ("columns"): newURI += '${model.listType}&listRows=${model.listRows}&listColumns=' + val + '&listOffset=${model.listOffset}'; break;
			case ("offset"):  newURI += '${model.listType}&listRows=${model.listRows}&listColumns=${model.listColumns}&listOffset=' + val; break;
		}
		persistentTopLinks(newURI);
	}
	function refreshPage() {
		window.location.href = window.location.href;
	}

function persistentTopLinks(newURI, follow) {
    var id;
    var follow = (typeof(follow)=="undefined") ? true : follow;
    var url = this.location;
    var m = url.toString().match(/.*\/(.+?)\./);
    if (m[1].match(/^.*Settings$/)) {
        m[1] = "settings";
    }
    switch (m[1]) {
        case "home": id = "homeLink"; break
        case "podcastReceiver": id = "podcastLink"; break
        case "status": id = "statusLink"; break
        case "more": case "db": id = "moreLink"; break
        case "logfile": id = "statusLink"; break
        case "settings": id = "settingsLink"; break
    }
    parent.upper.document.getElementById(id).href = newURI;
    parent.upper.document.getElementById(id + "Desc").href = newURI;
    if (follow) {
        parent.main.src = newURI;
        location = newURI;
    }
}
</script>
</html>
