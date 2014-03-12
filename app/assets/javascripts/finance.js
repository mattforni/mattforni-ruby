//= require chart

var QUOTE_URL = '/finance/quote';

mattforni.controller('FinanceController', function($scope) {
    $scope.accountSize = 0;
	$scope.lastTrade = 0;
	$scope.numShares = 0;
	$scope.positionSize = 0;
    $scope.risk = 5;
    $scope.stop = 25; 
    $scope.symbol = '';

	var a = 0;
	var r = 0;

	$scope.update = function(digest) {
		a = $scope.stop == 0 ? 0 : 100.0 / $scope.stop;
		r = $scope.accountSize * ($scope.risk / 100.0);
		$scope.positionSize = a * r;
		$scope.numShares = $scope.lastTrade == 0 ? 0 : $scope.positionSize / $scope.lastTrade;
		if (digest) { $scope.$digest(); }
	}

	$scope.quote = function() {
		// Makes symbol upper case for compliance 
		$scope.symbol = $scope.symbol.toUpperCase();
			$.ajax({
			accepts: 'json',
			data: {
				symbol: $scope.symbol 
			},
			dataType: 'json',
			type: 'GET',
			success: function(data, code, jqXHR) {
				$scope.lastTrade = data['lastTrade'];
				$scope.update(true);
			},
			url: QUOTE_URL
		});
	}
});

