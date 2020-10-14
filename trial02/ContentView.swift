//
//  ContentView.swift
//  trial02
//
//  Created by Aman Ilyasovich on 7/10/20.
//

import SwiftUI

struct ElementModel: Identifiable

{
    let id: Int
    var frame: CGRect
}

struct ContentView: View
{
    @State var elements: [ElementModel] =
        [
            ElementModel(id: 1, frame: CGRect(x: 50,  y: 220, width: 190, height: 250))
        ]
    
    @State var selectedID: Int?
    
    var body: some View
    {
        ZStack
        {
            Color.init("backgroud").edgesIgnoringSafeArea(.all)
                .onTapGesture { selectedID = nil }
            
            ForEach(elements.indices)
            {
                elementIndex in
                
                let isSelectedBinding = Binding<Bool>
                {
                    selectedID == elements[elementIndex].id
                }
                set:
                {
                    newValue in
                    
                    if(newValue)
                    {
                        selectedID = elements[elementIndex].id
                    }
                    else if selectedID == elements[elementIndex].id
                    {
                        selectedID = nil
                    }
                }
                
                RoundedRectangle(cornerRadius: 16.0, style: .continuous)
                    .fill(Color.white)
                    .overlay(VStack(spacing: 16)
                    {
                        Image("beach-img")
                        Text("Beach").font(.system(.headline))
                    })
                    .shadow(radius: 20, y: 20)
                    .modifier(DragResizable(frame: $elements[elementIndex].frame, isSelected: isSelectedBinding))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Group
        {
            ContentView()
        }
    }
}

struct DragResizable: ViewModifier
{
    @Binding var frame: CGRect
    @Binding var isSelected: Bool
    
    @State var initialDragDelta: CGSize?
    @State var isDragging = false
    
    func body(content: Content) -> some View
    {
        ZStack
        {
            content
                .frame(width: frame.width, height: frame.height, alignment: .center)
                .position(CGPoint(x: frame.midX, y: frame.midY))
                .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .global)
                            .onChanged
                            {
                                value in
                                
                                if initialDragDelta == nil
                                {
                                    initialDragDelta = CGSize(width: value.startLocation.x - frame.midX, height: value.startLocation.y - frame.midY)
                                    
                                    isDragging = true
                                    isSelected = false
                                }
                                
                                updateDragPosition(newValue: value.location)
                            }
                            .onEnded
                            {
                                value in
                                
                                initialDragDelta = nil
                                isDragging = false
                            }
                            .simultaneously(with: TapGesture().onEnded { isSelected.toggle() }))
            
            
            if(isSelected)
            {
                HandleBorder(frame: $frame, color: .black, width: 8)
                
                
                if(isDragging)
                {
                    Rectangle()
                        .fill(Color.gray)
                        .opacity(0.2)
                        .frame(width: frame.width, height: frame.height, alignment: .center)
                        .position(CGPoint(x: frame.midX, y: frame.midY))
                        .allowsHitTesting(false)
                }
                
                Group()
                {
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .leading,  vertical: .top))
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .center,   vertical: .top))
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .trailing, vertical: .top))
                    
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .leading,  vertical: .center))
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .trailing, vertical: .center))
                    
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .leading,  vertical: .bottom))
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .center,   vertical: .bottom))
                    HandleView(frame: $frame, anchorPostion:Alignment(horizontal: .trailing, vertical: .bottom))
                }
                
                HandleBorder(frame: $frame, color: .white, width: 4)
            }
        }
    }
    
    func updateDragPosition(newValue: CGPoint)
    {
        let midX = newValue.x - (initialDragDelta?.width ?? 0)
        let midY = newValue.y - (initialDragDelta?.height ?? 0)
        
        let minX = midX - frame.width / 2
        let minY = midY - frame.height / 2
        
        frame = CGRect(x: minX, y: minY, width: frame.width, height: frame.height)
    }
}

struct HandleBorder: View
{
    @Binding var frame: CGRect
    let color:Color
    let width:CGFloat
    
    var body: some View
    {
        ZStack
        {
            Rectangle()
                .stroke(color, lineWidth: width)
                .frame(width: frame.width, height: frame.height, alignment: .center)
                .position(CGPoint(x: frame.midX, y: frame.midY))
        }
    }
    
}

struct HandleView: View
{
    @Binding var frame: CGRect
    @State var initialDragDelta: CGSize?
    @State var isDragging = false
    
    let anchorPostion: Alignment
    let borderThickness: CGFloat = 1
    
    let handleSizeRegular: CGFloat = 12
    let handleSizeDragging: CGFloat = 50
    
    var handleSize: CGFloat { isDragging ? handleSizeDragging : handleSizeRegular }
    
    var handlePosition: CGPoint
    {
        var x: CGFloat
        var y: CGFloat
        
        switch anchorPostion.horizontal
        {
        case .leading:  x = frame.minX
        case .trailing: x = frame.maxX
        default:        x = frame.midX
        }
        
        switch anchorPostion.vertical
        {
        case .top:    y = frame.minY
        case .bottom: y = frame.maxY
        default:      y = frame.midY
        }
        
        return CGPoint(x: x, y: y)
    }
    
    func updateHandlePosition(newValue: CGPoint)
    {
        var minX = frame.minX
        var maxX = frame.maxX
        var minY = frame.minY
        var maxY = frame.maxY
        
        switch anchorPostion.horizontal
        {
        case .leading:  minX = newValue.x - (initialDragDelta?.width ?? 0)
        case .trailing: maxX = newValue.x - (initialDragDelta?.width ?? 0)
        default: break
        }
        
        switch anchorPostion.vertical
        {
        case .top:    minY = newValue.y - (initialDragDelta?.height ?? 0)
        case .bottom: maxY = newValue.y - (initialDragDelta?.height ?? 0)
        default: break
        }
        
        frame = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: (isDragging ? 27 : 4), style: .continuous)
                .fill(Color.black)
                .frame(width: handleSize + 1 * borderThickness, height: handleSize + 1 * borderThickness, alignment: .center)
            RoundedRectangle(cornerRadius: (isDragging ? 25 : 2), style: .continuous)
                .fill(Color.white)
                .frame(width: handleSize, height: handleSize, alignment: .center)
        }
        .frame(width: 60, height: 60, alignment: .center)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged
                    {
                        value in
                        
                        if initialDragDelta == nil
                        {
                            initialDragDelta = CGSize(width: value.startLocation.x - handlePosition.x, height: value.startLocation.y - handlePosition.y)
                            
                            withAnimation(.spring(response: 0.3, dampingFraction:0.3)) { isDragging = true }
                        }
                        
                        updateHandlePosition(newValue: value.location)
                    }
                    .onEnded
                    {
                        value in
                        
                        initialDragDelta = nil
                        withAnimation(.spring(response: 0.1, dampingFraction:0.6)) { isDragging = false }
                    })
        .position(handlePosition)
    }
}
