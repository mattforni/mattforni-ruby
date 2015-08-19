/**
 * This file contains all JavaScript logic pertinent to the finance pages.
 *
 * @author Matt Fornaciari (mattforni@gmail.com)
 */

var QUOTE_URL = '/finance/quote';

var requestQuote = function(symbol, success, error) {
    var request = $.ajax({
        accepts: 'json',
        dataType: 'json',
        type: 'GET',
        url: QUOTE_URL + '/' + symbol
    });

    // Bind the success and error handlers to the ajax request object if defined
    if (typeof error === 'function') { request.error(error); }
    if (typeof success === 'function') { request.success(success); }

    return request;
};

/**
 * Creates, scopes and binds the FinanceController to the angular module
 * defined in app/assets/javascripts/application.js. It should be noted the
 * '$scopes' declaration is necessary for clarification to the angular injector
 * due to the minfication process.
 */
finance.controller('SizingController', ['$scope',
    function($scope) {
        $scope.accountSize = 0;
        $scope.lastTrade = 0;
        $scope.numShares = 0;
        $scope.positionSize = 0;
        $scope.possibleLoss = 0;
        $scope.risk = 5;
        $scope.stop = 25;
        $scope.stopPrice = 0;
        $scope.symbol = "";

        var a = 0;
        var r = 0;

        /**
         * Formats the stock symbol and then attempts to retrieves a quote for
         * said symbol, updating the lastTrade value on success.
         */
        $scope.last_trade = function() {
            // Makes symbol upper case for compliance
            $scope.symbol = $scope.symbol.toUpperCase();
            var success = function(data, code, jqXHR) {
                $scope.lastTrade = data.lastTrade;
                $scope.update(true);
            };
            requestQuote($scope.symbol, success);
        } // End $scope.last_trade

        /**
         * Updates all variables associated with position sizing. 
         *
         * @params {boolean} digest Whether or not to digest the scope.
         */
        $scope.update = function(digest) {
            a = $scope.stop == 0 ? 0 : 100.0 / $scope.stop;
            r = $scope.accountSize * ($scope.risk / 100.0);
            $scope.positionSize = a * r;

            // If lastTrade is 0, ignore numShares and stopPrice
            if ($scope.lastTrade == 0) {
                $scope.numShares = 0;
                $scope.stopPrice = 0;
            } else  { // Else calculate the new values
                $scope.numShares = $scope.positionSize / $scope.lastTrade;
                $scope.stopPrice = ((100.0 - $scope.stop)/100.0) * $scope.lastTrade;
            }

            $scope.possibleLoss = ($scope.lastTrade - $scope.stopPrice) * $scope.numShares;
            if (digest) { $scope.$digest(); }
        } // End $scope.update
    } // End anonymous FunctionController function
]);

finance.controller('QuickQuoteController', ['$scope',
    function($scope) {
        $scope.fetching = false;
        $scope.quote = null;
        $scope.symbol = null;

        /**
         * Formats the stock symbol and then attempts to retrieves a quote
         */
        $scope.getQuote = function() {
            // If there is no symbol, nullify the quote and return
            if (!$scope.symbol || $scope.symbol.length === 0) {
                $scope.quote = null;
                return;
            }

            // If the quote has already been loaded, do not re-request
            if ($scope.quote && $scope.quote.symbol === $scope.symbol) { return; }

            // Makes symbol upper case for compliance
            $scope.symbol = $scope.symbol.toUpperCase();
            var error = function(data, code, jqXHR) {
                $scope.symbol = $scope.quote === null ? '' : $scope.quote.symbol
                $scope.$digest();
            };
            var success = function(data, code, jqXHR) {
                $scope.quote = data;
                $scope.$digest();
            };

            $scope.fetching = true;
            var request = requestQuote($scope.symbol, success, error);
            request.complete(function(jqXHR, code) {
                $scope.fetching = false;
                $scope.$digest();
            });
        }; // End $scope.getQuote

        $scope.positivityClass = function(value) {
            return value < 0 ? 'negative' : 'positive';
        }; // End $scope.positivityClass
    } // End anonymous QuickQuoteController function
]);

