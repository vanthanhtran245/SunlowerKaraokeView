//
//  RootViewController.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/20/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    
    let dataList:Array<MusicItem> = [
        MusicItem(
            title: "Thất tình",
            singer: "Trịnh Đình Quang",
            musicFileURL: NSURL(fileURLWithPath: Bundle.main.path(forResource: "ThatTinh", ofType: "mp3")!),
            lyricFileName: "that_tinh"
        ),
        
        MusicItem(
            title: "Tri kỷ",
            singer: "Phan Mạnh Quỳnh",
            musicFileURL: NSURL(fileURLWithPath: Bundle.main.path(forResource: "TryKy", ofType: "mp3")!),
            lyricFileName: "tri_ky"
        )
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath as IndexPath)
        
        let music = dataList[indexPath.row]
        
        cell.textLabel?.text = music.title
        cell.detailTextLabel?.text = music.singer
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = dataList[indexPath.row]
        
        if let playMusicVC = self.storyboard?.instantiateViewController(withIdentifier: "playMusicVC") as? PlayMusicViewController {
            
            let lyricParser = VTBasicKaraokeLyricParser()
            
            playMusicVC.songURL = music.musicFileURL
            playMusicVC.lyric   = lyricParser.lyricFromLocalPathFileName(lrcFileName: music.lyricFileName)
            
            self.navigationController?.pushViewController(playMusicVC, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
