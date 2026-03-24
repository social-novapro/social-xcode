//
//  DebugHarness.swift
//  social-apple
//
//  Created by Daniel Kravec on 2026-03-24.
//

import Foundation

struct DebugContractCheckResult: Identifiable {
	let id = UUID()
	let name: String
	let passed: Bool
	let details: String
}

struct DebugContractCheckReport {
	let ranAt: Date
	let results: [DebugContractCheckResult]

	var passedCount: Int {
		results.filter { $0.passed }.count
	}

	var failedCount: Int {
		results.count - passedCount
	}
}

enum DebugHarness {
	static func runContractBaselineChecks() -> DebugContractCheckReport {
		let debugTokens = UserTokenData(
			accessToken: "debug-access-token",
			userToken: "debug-user-token",
			userID: "debug-user-id"
		)

		let apiHelper = API_Helper(userTokensProv: debugTokens)
		let auth = AuthApi(apiHelper: apiHelper)
		let posts = PostsApi(apiHelper: apiHelper)
		let search = SearchApi(apiHelper: apiHelper)
		let notifications = NotificationsApi(apiHelper: apiHelper)

		var requestLog: [URLRequest] = []
		let requestLock = NSLock()

		InterceptedURLProtocol.requestHandler = { request in
			requestLock.lock()
			requestLog.append(request)
			requestLock.unlock()

			let path = request.url?.path ?? ""

			if path.hasSuffix("/auth/userLogin") {
				return stubResponse(status: 200, json: """
				{
				  "login": true,
				  "publicData": {},
				  "accessToken": "stub-access",
				  "userToken": "stub-user",
				  "userID": "stub-id"
				}
				""")
			}

			if path.hasSuffix("/feeds/userFeed/v2") {
				return stubResponse(status: 200, json: """
				{
				  "amount": 0,
				  "posts": []
				}
				""")
			}

			if path.contains("/search/tags/") {
				return stubResponse(status: 200, json: """
				{
				  "hashtags": [],
				  "users": [],
				  "found": true
				}
				""")
			}

			if path.hasSuffix("/notifications/push/deviceSettings") {
				return stubResponse(status: 200, json: """
				[
				  {
					"name": "likes",
					"value": true,
					"displayName": "Likes",
					"description": "Like notifications"
				  }
				]
				""")
			}

			return stubResponse(status: 200, json: "{}")
		}

		URLProtocol.registerClass(InterceptedURLProtocol.self)
		defer {
			URLProtocol.unregisterClass(InterceptedURLProtocol.self)
			InterceptedURLProtocol.requestHandler = nil
		}

		// Trigger request construction through existing client code paths.
		_ = awaitResult { completion in
			auth.userLoginRequest(
				userLogin: UserLoginData(username: "debug-user", password: "debug-pass"),
				completion: completion
			)
		}

		_ = awaitResult { completion in
			posts.getUserFeed(userTokens: debugTokens, completion: completion)
		}

		_ = awaitResult { completion in
			search.searchTagSuggestion(searchText: "@sample", completion: completion)
		}

		notifications.saveDeviceToken(deviceToken: "device-token-debug")
		_ = awaitResult { completion in
			notifications.getDeviceSettings(completion: completion)
		}

		requestLock.lock()
		let capturedRequests = requestLog
		requestLock.unlock()

		let authRequest = capturedRequests.first { $0.url?.path.hasSuffix("/auth/userLogin") == true }
		let feedRequest = capturedRequests.first { $0.url?.path.hasSuffix("/feeds/userFeed/v2") == true }
		let searchRequest = capturedRequests.first { $0.url?.path.contains("/search/tags/") == true }
		let pushRequest = capturedRequests.first { $0.url?.path.hasSuffix("/notifications/push/deviceSettings") == true }

		var results: [DebugContractCheckResult] = []

		let authPathValid = authRequest?.url?.path.hasSuffix("/auth/userLogin") == true
		results.append(
			DebugContractCheckResult(
				name: "Auth route/path",
				passed: authPathValid,
				details: "Expected suffix /auth/userLogin, got \(authRequest?.url?.path ?? "nil")"
			)
		)

		let authHeadersValid =
			authRequest?.value(forHTTPHeaderField: "username") == "debug-user" &&
			authRequest?.value(forHTTPHeaderField: "password") == "debug-pass" &&
			authRequest?.value(forHTTPHeaderField: "apptoken") == apiHelper.appToken &&
			authRequest?.value(forHTTPHeaderField: "devtoken") == apiHelper.devToken &&
			authRequest?.value(forHTTPHeaderField: "accesstoken") == debugTokens.accessToken &&
			authRequest?.value(forHTTPHeaderField: "usertoken") == debugTokens.userToken &&
			authRequest?.value(forHTTPHeaderField: "userid") == debugTokens.userID

		results.append(
			DebugContractCheckResult(
				name: "Auth header construction",
				passed: authHeadersValid,
				details: "Validates username/password + token headers on login request"
			)
		)

		let feedPathValid = feedRequest?.url?.path.hasSuffix("/feeds/userFeed/v2") == true
		results.append(
			DebugContractCheckResult(
				name: "Feed v2 route/path",
				passed: feedPathValid,
				details: "Expected suffix /feeds/userFeed/v2, got \(feedRequest?.url?.path ?? "nil")"
			)
		)

		let searchPath = searchRequest?.url?.path ?? ""
		let searchTransformValid = searchPath.hasSuffix("/search/tags/0sample")
		results.append(
			DebugContractCheckResult(
				name: "Search tag transform",
				passed: searchTransformValid,
				details: "Expected @sample -> /search/tags/0sample, got \(searchPath.isEmpty ? "nil" : searchPath)"
			)
		)

		let pushPathValid = pushRequest?.url?.path.hasSuffix("/notifications/push/deviceSettings") == true
		let pushMethodValid = pushRequest?.httpMethod == "POST"
		let pushBody = parseJsonObject(pushRequest?.httpBody)
		let pushBodyValid = (pushBody?["deviceToken"] as? String) == "device-token-debug"

		results.append(
			DebugContractCheckResult(
				name: "Push settings request body",
				passed: pushPathValid && pushMethodValid && pushBodyValid,
				details: "Validates POST /notifications/push/deviceSettings with body key deviceToken"
			)
		)

		let liveFrame = createLiveSendData(
			type: 10,
			mesType: 2,
			content: "",
			replyTo: nil,
			userTokenData: debugTokens
		)
		let frameJson = encodeJsonObject(liveFrame)
		let tokensJson = frameJson?["tokens"] as? [String: Any]
		let frameShapeValid =
			(frameJson?["type"] as? Int) == 10 &&
			(frameJson?["mesType"] as? Int) == 2 &&
			(frameJson?["apiVersion"] as? String) == "1.0" &&
			(frameJson?["userID"] as? String) == debugTokens.userID &&
			(tokensJson?["accesstoken"] as? String) == debugTokens.accessToken &&
			(tokensJson?["usertoken"] as? String) == debugTokens.userToken &&
			(tokensJson?["userid"] as? String) == debugTokens.userID

		results.append(
			DebugContractCheckResult(
				name: "Websocket handshake frame shape",
				passed: frameShapeValid,
				details: "Validates type/mesType/apiVersion/userID/tokens payload fields"
			)
		)

		return DebugContractCheckReport(ranAt: Date(), results: results)
	}

	private static func awaitResult<T>(timeout: TimeInterval = 3.0, _ invoke: (@escaping (Result<T, Error>) -> Void) -> Void) -> Result<T, Error>? {
		let semaphore = DispatchSemaphore(value: 0)
		var result: Result<T, Error>?

		invoke { callbackResult in
			result = callbackResult
			semaphore.signal()
		}

		let waitResult = semaphore.wait(timeout: .now() + timeout)
		guard waitResult == .success else {
			return nil
		}

		return result
	}

	private static func stubResponse(status: Int, json: String) -> InterceptedURLProtocol.Stub {
		InterceptedURLProtocol.Stub(
			statusCode: status,
			headers: ["Content-Type": "application/json"],
			body: Data(json.utf8)
		)
	}

	private static func parseJsonObject(_ data: Data?) -> [String: Any]? {
		guard let data else { return nil }
		guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
			return nil
		}
		return object
	}

	private static func encodeJsonObject<T: Encodable>(_ value: T) -> [String: Any]? {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(value) else {
			return nil
		}
		return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
	}
}

private final class InterceptedURLProtocol: URLProtocol {
	struct Stub {
		let statusCode: Int
		let headers: [String: String]
		let body: Data
	}

	static var requestHandler: ((URLRequest) -> Stub)?

	override class func canInit(with request: URLRequest) -> Bool {
		guard let scheme = request.url?.scheme?.lowercased() else { return false }
		return scheme == "http" || scheme == "https"
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}

	override func startLoading() {
		guard let handler = Self.requestHandler,
			  let url = request.url else {
			client?.urlProtocol(self, didFailWithError: URLError(.badURL))
			return
		}

		let stub = handler(request)
		let response = HTTPURLResponse(
			url: url,
			statusCode: stub.statusCode,
			httpVersion: "HTTP/1.1",
			headerFields: stub.headers
		)

		guard let response else {
			client?.urlProtocol(self, didFailWithError: URLError(.cannotParseResponse))
			return
		}

		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		client?.urlProtocol(self, didLoad: stub.body)
		client?.urlProtocolDidFinishLoading(self)
	}

	override func stopLoading() {}
}

