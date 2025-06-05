import SwiftUI
import WebKit

struct WebChartView: UIViewRepresentable {
    var symbol: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.loadHTMLString(htmlString(for: symbol), baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString(for: symbol), baseURL: nil)
    }

    private func htmlString(for symbol: String) -> String {
        let upperSymbol = symbol.uppercased()
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    background-color: #fff;
                    height: 100%;
                    width: 100%;
                }
                #chart {
                    width: 100%;
                    height: 100%;
                }
            </style>
        </head>
        <body>
            <div id="chart"></div>
            <script src="https://unpkg.com/lightweight-charts/dist/lightweight-charts.standalone.production.js"></script>
            <script>
                const chart = LightweightCharts.createChart(document.getElementById('chart'), {
                    width: 360,
                    height: 300,
                    layout: {
                        background: { color: '#ffffff' },
                        textColor: '#000000',
                    },
                    grid: {
                        vertLines: { color: '#e1e1e1' },
                        horzLines: { color: '#e1e1e1' }
                    },
                    timeScale: {
                        timeVisible: true,
                        secondsVisible: false
                    }
                });

                const series = chart.addCandlestickSeries();

                fetch('https://api.binance.com/api/v3/klines?symbol=\(upperSymbol)&interval=1h&limit=100')
                    .then(res => res.json())
                    .then(data => {
                        const formatted = data.map(d => ({
                            time: Math.floor(d[0] / 1000),
                            open: parseFloat(d[1]),
                            high: parseFloat(d[2]),
                            low: parseFloat(d[3]),
                            close: parseFloat(d[4])
                        }));
                        series.setData(formatted);
                    });
            </script>
        </body>
        </html>
        """
    }
}
