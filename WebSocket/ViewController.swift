//
//  ViewController.swift
//  WebSocket
//
//  Created by JeongminKim on 2022/04/09.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.center = view.center
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        })
    }
    
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let newMessage: Int = Int.random(in: 0...99)
            self.send()
            self.webSocket?.send(.string("Send new message: \(newMessage)"), completionHandler: { error in
                if let error = error {
                    print("Send error: \(error)")
                } else {
                    print("Sent successfully from client - message: \(newMessage)")
                }
            })
        }
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got data from server: \(data)")
                case .string(let message):
                    print("Got message from server: \(message)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error from server: \(error)")
            }
            
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason: \(reason)")
    }
}

