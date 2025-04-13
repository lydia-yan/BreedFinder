//
//  ContentView.swift
//  DogPhotoUploader
//
//  Created by Moyan on 4/12/25
//

import SwiftUI
import PhotosUI
import Photos
import UIKit

// Define the model for parsing API responses
struct DogBreedPrediction: Codable, Identifiable {
    let breed: String
    let probability: Double
    
    var id: String { breed }
    
    var formattedProbability: String {
        return String(format: "%.1f%%", probability * 100)
    }
}

struct PredictionResponse: Codable {
    let predictions: [DogBreedPrediction]
    let filename: String
}

struct ContentView: View {
    @State private var selectedImageData: Data?
    @State private var selectedImage: Image?
    @State private var showImagePicker = false
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var predictionResult: PredictionResponse?
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 30)
                // Title Area
                Text("BreedFinder")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 0)
                
                Spacer().frame(height: 35)
                
                // Display Selected Image
                if let image = selectedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                        .padding()
                } else {
                    Image("dog_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320, height: 280)
                        .clipped()
                    
                    Text("Please select a photo of your dog ⬇️")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                // Display the prediction results
                if showResults, let predictions = predictionResult?.predictions, !predictions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Breed Predictions:")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(predictions.prefix(3)) { prediction in
                            HStack {
                                Text(prediction.breed)
                                    .font(.subheadline)
                                Spacer()
                                Text(prediction.formattedProbability)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            //Progress bar displays probability
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 8)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                    
                                    Rectangle()
                                        .frame(width: geometry.size.width * CGFloat(prediction.probability), height: 8)
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    
                    // Add "Back to Homepage" button outside and below the gray box
                    Button(action: {
                        // Reset to initial state
                        showResults = false
                        selectedImage = nil
                        selectedImageData = nil
                        predictionResult = nil
                    }) {
                        Text("Back to Homepage")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                } else {
                    Spacer().frame(height: 30)
                }
                
                Spacer().frame(maxHeight: 50)
                
                // Only show these buttons when not displaying results
                if !showResults {
                    // Select Photo Button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Select Photo")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                    
                    // Upload Button
                    Button(action: {
                        uploadImage()
                    }) {
                        Text(isUploading ? "Uploading..." : "Upload Photo")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedImage == nil ? Color.gray : Color.green)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(selectedImage == nil || isUploading)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                PhotoPickerView(imageData: $selectedImageData, selectedImage: $selectedImage, showAlert: $showAlert, alertTitle: $alertTitle, alertMessage: $alertMessage)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func uploadImage() {
        guard let imageData = selectedImageData else { return }
        
        isUploading = true
        showResults = false // Reset result display
        
        // Call the actual upload function
        uploadImageToServer(imageData)
    }
    
    // actual upload function
    func uploadImageToServer(_ imageData: Data) {
        // create request
        let url = URL(string: "http://127.0.0.1:8000/predict/")! //real API
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the multipart/form-data boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create request body
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"dogphoto.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End tag
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create request body
        request.httpBody = body
        
        // send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isUploading = false
                
                if let error = error {
                    self.alertTitle = "Upload Failed"
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.alertTitle = "Upload Failed"
                    self.alertMessage = "Server returned an error status code"
                    self.showAlert = true
                    return
                }
                
                // Parse the response data
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        self.predictionResult = try decoder.decode(PredictionResponse.self, from: data)
                        self.showResults = true
                        
                        self.alertTitle = "Breed Identification Complete"
                        self.alertMessage = "Analysis completed successfully!"
                        self.showAlert = true
                    } catch {
                        print("JSON parse wrong: \(error.localizedDescription)")
                        self.alertTitle = "Processing Error"
                        self.alertMessage = "Could not process the server response: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                } else {
                    self.alertTitle = "Upload Successful"
                    self.alertMessage = "Your dog's photo has been successfully uploaded, but no prediction data was returned."
                    self.showAlert = true
                }
            }
        }.resume()
    }
}

// Photo Picker View with Camera Option
struct PhotoPickerView: View {
    @Binding var imageData: Data?
    @Binding var selectedImage: Image?
    @Binding var showAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    @Environment(\.presentationMode) var presentationMode
    @State private var showCamera = false
    @State private var photoItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            // Photo Library Button - 直接使用 PhotosPicker
            PhotosPicker(
                selection: $photoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Select from Photo Library")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .onChange(of: photoItem) { oldItem, newItem in
                if let newItem = newItem {
                    loadTransferable(from: newItem)
                }
            }
            
            // Take Photo Button
            Button {
                showCamera = true
            } label: {
                Text("Take Photo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .presentationDetents([.medium])
        .sheet(isPresented: $showCamera) {
            CameraView(imageData: $imageData, selectedImage: $selectedImage, showAlert: $showAlert, alertTitle: $alertTitle, alertMessage: $alertMessage, presentationMode: presentationMode)
        }
    }
    
    // Load transferable function remains the same
    private func loadTransferable(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if isJPEGOrPNG(data: data ?? Data()) {
                        self.imageData = data
                        if let uiImage = UIImage(data: data ?? Data()) {
                            self.selectedImage = Image(uiImage: uiImage)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        self.alertTitle = "Invalid Format"
                        self.alertMessage = "Please select a JPG or PNG image"
                        self.showAlert = true
                    }
                case .failure(let error):
                    self.alertTitle = "Error"
                    self.alertMessage = "Failed to load image: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }

    private func isJPEGOrPNG(data: Data) -> Bool {
        // JPEG file header identifier is FF D8 FF
        if data.count >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF {
            return true
        }
        
        // PNG file header identifier is 89 50 4E 47 0D 0A 1A 0A
        if data.count >= 8 &&
            data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47 &&
            data[4] == 0x0D && data[5] == 0x0A && data[6] == 0x1A && data[7] == 0x0A {
            return true
        }
        
        return false
    }
}

// Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Binding var selectedImage: Image?
    @Binding var showAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    var presentationMode: Binding<PresentationMode>
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // Convert UIImage to JPEG data
                if let jpegData = image.jpegData(compressionQuality: 0.8) {
                    parent.imageData = jpegData
                    parent.selectedImage = Image(uiImage: image)
                    
                    // Close the camera view and the photo picker view
                    picker.dismiss(animated: true) {
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    parent.alertTitle = "Error"
                    parent.alertMessage = "Failed to convert image"
                    parent.showAlert = true
                    picker.dismiss(animated: true)
                }
            } else {
                picker.dismiss(animated: true)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
