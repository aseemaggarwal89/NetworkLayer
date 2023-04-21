# NetworkLayer

Network layer is the critical part in any mobile application. I have seen multiple projects with scattered and unformatted network logic without using abstraction and clear separation of responsibility that make developer life hell in long term either inducing new APIs or changing. I have face multiple challenges to incorporate such projects while working on any feature. Therefore, objective of this repository is to showcase the way to provide structured and readable
code. 

Network layer designed in this repository based on key aspects abstraction, separation of responsibility, protocol, layered and scalable. We have created a network layer over the networking library Alamofire

High level Design :

1) Base Folder -> Have files that is the core part of the network service

a)  BaseAPIClient -> This is the main file that provide implementation using Alamofire  to execute any HTTP request 
b) APIRequest -> this file define protocol to provide request information 
c) APIData -> this file provide entity and decodable logic
 
Note: This files will be abstract to other modules of the app.

2) API Folder -> Have files to provide the logic to define different Rest APIs required in the app and provide the network service to request data. 

A) AppRequestPaths -> Provide all the path used in the application
B) AppRequestInfo -> entity to provide information required to create HTTP request
C) AppRequestType -> Define all the required HTTP request used in the app
D) AppAPIRequest -> Implement protocol APIRequestProtocol 
E) AppNetworkManager -> this is the service class that execute app https request. 

Note: Used Dependency Injection in the project to use network service instance instead of using singleton directly


3) UseCases: This folder will provide different files to handle use cases required in the application. Each use case file will provide specific API repository functionality that could be integrated in other modules.

For demo purpose provide the two use case file UploadUseCase and PostUseCase

 
Design:

ViewController -> GroupDetailsAPIRepositoryProtocol ->  AppNetworkProtcol
