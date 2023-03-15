import UIKit
import AVFoundation

class SoundboardViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soundTableView: UITableView!
    @IBOutlet weak var menuButton: UIButton!
    
    private var soundList: [String] = []
    private var players: [AVAudioPlayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        setupMenuButton()
        setupSoundList()
        soundTableView.dataSource = self
        soundTableView.delegate = self
    }
    
    private func setupLabel(){
        titleLabel.text = "Soundboard"
    }
    
    private func setupSoundList(folderName: String? = nil){
        soundList = []
        let files = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        for file in files{
            let fileName = (file.components(separatedBy: "/").last ?? "").replacingOccurrences(of: ".mp3", with: "")
            if(folderName != nil){
                if(fileName.components(separatedBy: "%")[0] == folderName){
                    soundList.append(fileName)
                }
            }else{
                soundList.append(fileName)
            }
        }
        titleLabel.text = folderName ?? "Soundboard"
        
        //sort alpabetically
        soundList.sort(by: {$0 < $1})
        soundTableView.reloadData()
    }
    
    private func playSound(soundName: String){
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }

        //used to play multiple sounds at the same time
        do {
            let soundPlayer = try AVAudioPlayer( contentsOf: url )
            soundPlayer.numberOfLoops = 0
            soundPlayer.volume = 1
            soundPlayer.play()
            players.append(soundPlayer)
        } catch let error {
            print(error.localizedDescription)
        }
        
        cleanSoundPlayers()
    }
    
    private func cleanSoundPlayers(){
        for player in players {
            if player.isPlaying { continue } else {
                if let index = players.firstIndex(of: player) {
                    players.remove(at: index)
                    break
                }
            }
        }
    }
    
    private func setupMenuButton(){
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(title: "Folders", children: getSoundFoldersAsMenuArray())
    }
    
    private func getSoundFoldersAsMenuArray() -> [UIAction]{
        let folderNamesArray = getSoundFoldersNames()
        var menuActionArray: [UIAction] = [UIAction(title: "All", handler: { _ in
            self.setupSoundList(folderName: nil)
        })]
        for folder in folderNamesArray{
            menuActionArray.append(UIAction(title: folder, image: UIImage(named: "folder-fill"), handler: { _ in
                self.setupSoundList(folderName: folder)
            }))
        }
        return menuActionArray
    }
    
    private func getSoundFoldersNames() -> [String]{
        var folderArray: [String] = []
        let files = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        for file in files{
            let fileName = (file.components(separatedBy: "/").last ?? "").replacingOccurrences(of: ".mp3", with: "")
            if(fileName.contains("%") && !folderArray.contains(where: {$0 == fileName.components(separatedBy: "%")[0]})){
                folderArray.append(fileName.components(separatedBy: "%")[0])
            }
        }
        return folderArray
    }

}

extension SoundboardViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "soundCellId", for: indexPath) as? SoundboardCell {
            var fileName = soundList[indexPath.row]
            if(fileName.contains("%")){
                fileName = fileName.components(separatedBy: "%")[1]
            }
            cell.titleLabel.text = fileName
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playSound(soundName: soundList[indexPath.row])
    }
    
}

