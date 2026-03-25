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
		print("[DebugHarness] Starting contract baseline checks")
		let debugTokens = UserTokenData(
			accessToken: "debug-access-token",
			userToken: "debug-user-token",
			userID: "debug-user-id"
		)

		let apiHelper = API_Helper(userTokensProv: debugTokens)
		let apiClient = ApiClient(apiHelper: apiHelper)
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
            
            if path.hasSuffix("/notifications/push/register") {
                return stubResponse(status: 200, json: """
                 {
                   "msg": "registered"
                 }
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
			_ = awaitResult { completion in
				notifications.registerDevice(
					notificationRegister: PushNotificationSend(
						deviceToken: "device-token-debug",
						deviceType: "iPhone",
						userID: debugTokens.userID
					),
					completion: completion
				)
			}

			requestLock.lock()
			let capturedRequests = requestLog
			requestLock.unlock()
			print("[DebugHarness] Captured request count: \(capturedRequests.count)")

		let authRequest = capturedRequests.first { $0.url?.path.hasSuffix("/auth/userLogin") == true }
			let feedRequest = capturedRequests.first { $0.url?.path.hasSuffix("/feeds/userFeed/v2") == true }
			let searchRequest = capturedRequests.first { $0.url?.path.contains("/search/tags/") == true }
			let pushRequest = capturedRequests.first { $0.url?.path.hasSuffix("/notifications/push/deviceSettings") == true }
			let pushRegisterRequest = capturedRequests.first { $0.url?.path.hasSuffix("/notifications/push/register") == true }
			print("[DebugHarness] Push settings request path: \(pushRequest?.url?.path ?? "nil"), method: \(pushRequest?.httpMethod ?? "nil")")
			print("[DebugHarness] Push register request path: \(pushRegisterRequest?.url?.path ?? "nil"), method: \(pushRegisterRequest?.httpMethod ?? "nil")")

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
					details: "Validates username/password + token headers on login request (\(authRequest?.allHTTPHeaderFields?.count ?? 0) headers)"
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
			let pushBody = parseJsonObject(extractHttpBody(from: pushRequest))
			let pushBodyValid = (pushBody?["deviceToken"] as? String) == "device-token-debug"
			print("[DebugHarness] Push settings body: \(pushBody ?? [:])")
			print("[DebugHarness] Push settings check flags: path=\(pushPathValid) method=\(pushMethodValid) body=\(pushBodyValid)")

		results.append(
			DebugContractCheckResult(
					name: "Push settings request body",
					passed: pushPathValid && pushMethodValid && pushBodyValid,
					details: "Validates POST /notifications/push/deviceSettings with body key deviceToken"
				)
			)

			let pushRegisterPathValid = pushRegisterRequest?.url?.path.hasSuffix("/notifications/push/register") == true
			let pushRegisterMethodValid = pushRegisterRequest?.httpMethod == "POST"
			let pushRegisterBody = parseJsonObject(extractHttpBody(from: pushRegisterRequest))
			let pushRegisterBodyValid =
				(pushRegisterBody?["deviceToken"] as? String) == "device-token-debug" &&
				(pushRegisterBody?["deviceType"] as? String) == "iPhone" &&
				(pushRegisterBody?["userID"] as? String) == debugTokens.userID

			let pushRegisterHeadersValid =
				pushRegisterRequest?.value(forHTTPHeaderField: "apptoken") == apiHelper.appToken &&
				pushRegisterRequest?.value(forHTTPHeaderField: "devtoken") == apiHelper.devToken &&
				pushRegisterRequest?.value(forHTTPHeaderField: "accesstoken") == debugTokens.accessToken &&
				pushRegisterRequest?.value(forHTTPHeaderField: "usertoken") == debugTokens.userToken &&
				pushRegisterRequest?.value(forHTTPHeaderField: "userid") == debugTokens.userID
			print("[DebugHarness] Push register body: \(pushRegisterBody ?? [:])")
			print("[DebugHarness] Push register headers: apptoken=\(pushRegisterRequest?.value(forHTTPHeaderField: "apptoken") ?? "nil"), devtoken=\(pushRegisterRequest?.value(forHTTPHeaderField: "devtoken") ?? "nil"), accesstoken=\(pushRegisterRequest?.value(forHTTPHeaderField: "accesstoken") ?? "nil"), usertoken=\(pushRegisterRequest?.value(forHTTPHeaderField: "usertoken") ?? "nil"), userid=\(pushRegisterRequest?.value(forHTTPHeaderField: "userid") ?? "nil")")
			print("[DebugHarness] Push register check flags: path=\(pushRegisterPathValid) method=\(pushRegisterMethodValid) body=\(pushRegisterBodyValid) headers=\(pushRegisterHeadersValid)")

			results.append(
				DebugContractCheckResult(
					name: "T14 Push register route/body",
					passed: pushRegisterPathValid && pushRegisterMethodValid && pushRegisterBodyValid,
					details: "Expected POST /notifications/push/register with deviceToken/deviceType/userID body"
				)
			)

			results.append(
				DebugContractCheckResult(
					name: "T14 Push register token headers",
					passed: pushRegisterHeadersValid,
					details: "Validates apptoken/devtoken/accesstoken/usertoken/userid on register request"
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

			let updatedTokens = UserTokenData(
				accessToken: "updated-access-token",
				userToken: "updated-user-token",
				userID: "updated-user-id"
			)
			apiClient.updateUserTokens(userTokens: updatedTokens)
			awaitMainQueueDrain()

				let clientTokens = apiClient.userTokens
				let helperTokens = apiClient.apiHelper.userTokens
				let notificationsTokens = apiClient.notifications.apiHelper.userTokens
				let postsTokens = apiClient.posts.apiHelper.userTokens
				let usersTokens = apiClient.users.apiHelper.userTokens

				let tokenPropagationValid =
					clientTokens.accessToken == updatedTokens.accessToken &&
					clientTokens.userToken == updatedTokens.userToken &&
					clientTokens.userID == updatedTokens.userID &&
					helperTokens.accessToken == updatedTokens.accessToken &&
					helperTokens.userToken == updatedTokens.userToken &&
					helperTokens.userID == updatedTokens.userID &&
					notificationsTokens.accessToken == updatedTokens.accessToken &&
					notificationsTokens.userToken == updatedTokens.userToken &&
					notificationsTokens.userID == updatedTokens.userID &&
					postsTokens.accessToken == updatedTokens.accessToken &&
					postsTokens.userToken == updatedTokens.userToken &&
					postsTokens.userID == updatedTokens.userID &&
					usersTokens.accessToken == updatedTokens.accessToken &&
					usersTokens.userToken == updatedTokens.userToken &&
					usersTokens.userID == updatedTokens.userID

			results.append(
				DebugContractCheckResult(
					name: "T11 Token lifecycle propagation",
					passed: tokenPropagationValid,
					details: "Validates ApiClient.updateUserTokens updates shared helper and route services"
				)
			)

			let sharedServiceChainValid =
				ObjectIdentifier(apiClient.apiHelper) == ObjectIdentifier(apiClient.notifications.apiHelper) &&
				ObjectIdentifier(apiClient.apiHelper) == ObjectIdentifier(apiClient.posts.apiHelper) &&
				ObjectIdentifier(apiClient.apiHelper) == ObjectIdentifier(apiClient.users.apiHelper) &&
				ObjectIdentifier(apiClient.apiHelper) == ObjectIdentifier(apiClient.search.apiHelper) &&
				ObjectIdentifier(apiClient.apiHelper) == ObjectIdentifier(apiClient.admin.apiHelper)

			results.append(
				DebugContractCheckResult(
					name: "T7/T10 Shared API service chain",
					passed: sharedServiceChainValid,
					details: "Validates route clients share one API_Helper instance after lifecycle updates"
				)
			)

			results.append(
				DebugContractCheckResult(
					name: "T15 Smoke evidence captured",
					passed: !capturedRequests.isEmpty,
					details: "Captured \(capturedRequests.count) intercepted requests at \(ISO8601DateFormatter().string(from: Date()))"
				)
			)

			let report = DebugContractCheckReport(ranAt: Date(), results: results)
			print("[DebugHarness] Contract checks complete: passed \(report.passedCount)/\(report.results.count)")
			return report
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

	private static func extractHttpBody(from request: URLRequest?) -> Data? {
		guard let request else {
			return nil
		}

		if let body = request.httpBody, !body.isEmpty {
			return body
		}

		guard let stream = request.httpBodyStream else {
			return nil
		}

		stream.open()
		defer { stream.close() }

		let bufferSize = 1024
		var data = Data()
		var buffer = [UInt8](repeating: 0, count: bufferSize)

		while stream.hasBytesAvailable {
			let read = stream.read(&buffer, maxLength: bufferSize)
			if read < 0 {
				return nil
			}
			if read == 0 {
				break
			}
			data.append(buffer, count: read)
		}

		return data.isEmpty ? nil : data
	}

	private static func encodeJsonObject<T: Encodable>(_ value: T) -> [String: Any]? {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(value) else {
			return nil
		}
		return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
	}

	private static func awaitMainQueueDrain(timeout: TimeInterval = 1.0) {
		let semaphore = DispatchSemaphore(value: 0)
		DispatchQueue.main.async {
			semaphore.signal()
		}
		_ = semaphore.wait(timeout: .now() + timeout)
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
