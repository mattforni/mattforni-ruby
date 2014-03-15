//= require chart

var LAST_TRADE_URL = '/finance/last_trade';

function FinanceController($scope) {
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

    $scope.last_trade = function() {
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
                $scope.lastTrade = data
                $scope.update(true);
            },
            url: LAST_TRADE_URL
        });
    }
}

