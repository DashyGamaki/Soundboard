import UIKit
import AVFoundation

class SoundboardViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soundTableView: UITableView!
    
    var soundList: [String] = []
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        setupSoundList()
        soundTableView.dataSource = self
        soundTableView.delegate = self
    }
    
    private func setupLabel(){
        titleLabel.text = "Soundboard"
    }
    
    private func setupSoundList(){
        let files = Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
        for file in files{
            let fileName = (file.components(separatedBy: "/").last ?? "").replacingOccurrences(of: ".mp3", with: "")
            soundList.append(fileName)
        }
        soundTableView.reloadData()
    }
    
    func playSound(soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)


            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension SoundboardViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "soundCellId", for: indexPath) as? SoundboardCell {
            cell.titleLabel.text = soundList[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playSound(soundName: soundList[indexPath.row])
    }
    
}

