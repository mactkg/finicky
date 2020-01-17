import Foundation

class ResolveShortUrls: NSObject, URLSessionTaskDelegate {
    fileprivate var shortUrlResolver: FNShortUrlResolver?

    init(shortUrlResolver: FNShortUrlResolver) {
        self.shortUrlResolver = shortUrlResolver
        super.init()
    }

    func urlSession(_: URLSession, task _: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("urlSession \(request.url?.path) also \(response.statusCode) etc \(response.url?.path)")
        var newRequest: URLRequest? = request

        var res = shortUrlResolver!.isShortUrl(response.url!)
        if  !res {
            print("isnt short")
            newRequest = nil
        } else {
            print("is long b o y")
        }
//
//        var res = shortUrlResolver!.isShortUrl(request.url!)
//        print("is it intersting? \(res) ok boy \(request.url)")
//
//        if [301, 302, 309].contains(response.statusCode) {
//            print("newurl \(response.allHeaderFields["Location"] as? String)")
//            let newUrl = request.url ?? URL(string: (response.allHeaderFields["Location"] as? String)!)
//
//            if (newUrl != nil) {
//                print("is it a new short url?")
//                if !shortUrlResolver!.isShortUrl(newUrl!) {
//                    print("no it's not")
//                    newRequest = nil
//                } else {
//                    print("yes it is...")
//                }
//            } else {
//
//                print("Nope newURL was nil I guess...? \(newUrl)")
//            }
//        }
//        print("completion with \(newRequest)")
        completionHandler(newRequest)
    }
}

let defaultUrlShorteners = [
    "adf.ly",
    "bit.do",
    "bit.ly",
    "buff.ly",
    "deck.ly",
    "fur.ly",
    "goo.gl",
    "is.gd",
    "mcaf.ee",
    "ow.ly",
    "spoti.fi",
    "su.pr",
    "t.co",
    "tiny.cc",
    "tinyurl.com",
]



class FNShortUrlResolver {
    private var shortUrlProviders: [String] = []
    var version: String

    init() {
        shortUrlProviders = defaultUrlShorteners
        version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    init(shortUrlProviders: [String]?) {
        self.shortUrlProviders = shortUrlProviders ?? defaultUrlShorteners
        version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    func isShortUrl(_ url: URL) -> Bool {
        if url.host == nil {
            return false
        }

        let isShortUrlProvider = shortUrlProviders.contains(url.host!)

        if !isShortUrlProvider {
            return false
        }

        // Can't load insecure cleartext HTTP
        // https://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
        if url.scheme == "https" {
            return true
        }

        return false
    }

    func resolveUrl(_ url: URL, callback: @escaping ((URL) -> Void)) {
        if !isShortUrl(url) {
            callback(url)
            return
        }
        print("resolving the url, hey")
        var request = URLRequest(url: url)
        request.setValue("finicky/\(version)", forHTTPHeaderField: "User-Agent")
        let myDelegate = ResolveShortUrls(shortUrlResolver: self)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: myDelegate, delegateQueue: nil)

        let task = session.dataTask(with: request, completionHandler: { (_, response, _) -> Void in

            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! the response is \(response!.url)")
            if let httpResponse: HTTPURLResponse = response as? HTTPURLResponse {

                print("responsed \(httpResponse.url)")
                let newUrl = httpResponse.url
                callback(httpResponse.url ?? url)
            } else {
                callback(url)
            }

        })

        task.resume()
        return
    }
}
